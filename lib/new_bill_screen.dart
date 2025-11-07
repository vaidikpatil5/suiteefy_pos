import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../db/database_helper.dart';
import '../models/product.dart';
import '../utils/contact_picker.dart';
import 'billing_summary_screen.dart';
import '../theme.dart';
import '../widgets/mandala_background.dart';

class NewBillScreen extends StatefulWidget {
  const NewBillScreen({super.key});

  @override
  State<NewBillScreen> createState() => _NewBillScreenState();
}

class _NewBillScreenState extends State<NewBillScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  List<Product> scannedProducts = [];

  Future<void> _scanProduct() async {
    // Navigate to a simple scanner page and get the scanned code
    final code = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (code != null && code is String) {
      final db = DatabaseHelper.instance;
      final product = await db.getProductById(code);
      if (product != null) {
        setState(() => scannedProducts.add(product));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No product found for code: $code")),
        );
      }
    }
  }

  Future<void> _searchProduct() async {
    final selectedProduct = await showSearch<Product?>(
      context: context,
      delegate: ProductSearchDelegate(),
    );

    if (selectedProduct != null) {
      setState(() {
        scannedProducts.add(selectedProduct);
      });
    }
  }

  void _nextButtonPressed() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter customer name and phone number."),
        ),
      );
      return;
    }

    if (phone.length != 10 || int.tryParse(phone) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit phone number."),
        ),
      );
      return;
    }

    if (scannedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Add at least one product before proceeding."),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillingSummaryScreen(
          customerName: name,
          phoneNumber: phone,
          items: scannedProducts
              .map(
                (p) => BillingItem(
                  productId: p.productId,
                  name: p.name,
                  price: p.price,
                  quantity: 1,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MandalaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Create New Bill")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Customer Name",
                  border: OutlineInputBorder(),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.contacts),
                    onPressed: () async {
                      final contactData = await pickContact(context);
                      if (contactData != null) {
                        setState(() {
                          _nameController.text = contactData['name']!;
                          _phoneController.text = contactData['phone']!;
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _scanProduct,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("Add Item (Scan)"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _searchProduct,
                icon: const Icon(Icons.search),
                label: const Text("Add Item (Search)"),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: scannedProducts.length,
                  itemBuilder: (context, index) {
                    final item = scannedProducts[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text("Price: ₹${item.price}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() => scannedProducts.removeAt(index));
                        },
                      ),
                    );
                  },
                ),
              ),

              ElevatedButton.icon(
                onPressed: () => _nextButtonPressed(),
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Next"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.roseDust,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<Product?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Search for products by name'));
    }

    final db = DatabaseHelper.instance;

    return FutureBuilder<List<Product>>(
      future: db.searchProductsByName(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found.'));
        }

        final results = snapshot.data!;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final product = results[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('₹${product.price}'),
              onTap: () => close(context, product),
            );
          },
        );
      },
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isScanning = false;

  void handleDetection(BarcodeCapture capture) {
    if (isScanning) return; // prevent double detection
    final String? code = capture.barcodes.first.rawValue;

    if (code != null && code.isNotEmpty) {
      setState(() => isScanning = true);
      cameraController.stop();

      // Delay slightly to allow UI stability
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pop(context, code);
      });
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: handleDetection,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.satinGold, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (isScanning)
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.deepCocoa.withOpacity(0.5),
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
