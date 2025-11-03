import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/product.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  List<Product> inventory = [];
  List<Product> selectedItems = [];
  double total = 0.0;
  double discount = 0.0;

  @override
  void initState() {
    super.initState();
    loadInventory();
  }

  Future<void> loadInventory() async {
    final db = DatabaseHelper.instance;
    final all = await db.getAllProducts();
    setState(() => inventory = all);
  }

  void addItem(Product p) {
    setState(() {
      selectedItems.add(p);
      total += p.price;
    });
  }

  void removeItem(Product p) {
    setState(() {
      selectedItems.remove(p);
      total -= p.price;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Bill')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            const Text('Add Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButton<Product>(
              hint: const Text('Select Product'),
              isExpanded: true,
              items: inventory.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text('${p.name} - ₹${p.price}'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) addItem(val);
              },
            ),
            const Divider(),
            const Text('Selected Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedItems.length,
              itemBuilder: (_, i) {
                final item = selectedItems[i];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('₹${item.price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeItem(item),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text('Total: ₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: 'Discount (₹)'),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                setState(() {
                  discount = double.tryParse(val) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 10),
            Text('Net Total: ₹${(total - discount).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bill saved (mock)')));
              },
              child: const Text('Save Bill'),
            )
          ],
        ),
      ),
    );
  }
}
