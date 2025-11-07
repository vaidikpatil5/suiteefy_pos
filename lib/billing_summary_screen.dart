import 'package:flutter/material.dart';
import '../utils/pdf_generator.dart';
import '../models/bill.dart';
import '../models/bill_item.dart';
import '../db/database_helper.dart';
import '../widgets/mandala_background.dart';

// Temporary wrapper for billing
class BillingItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  BillingItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;
}

class BillingSummaryScreen extends StatefulWidget {
  final String customerName;
  final String phoneNumber;
  final List<BillingItem> items; // [{name, price, qty}, ...]

  const BillingSummaryScreen({
    super.key,
    required this.customerName,
    required this.phoneNumber,
    required this.items,
  });

  @override
  State<BillingSummaryScreen> createState() => _BillingSummaryScreenState();
}

class _BillingSummaryScreenState extends State<BillingSummaryScreen> {
  final TextEditingController _discountController = TextEditingController();
  String discountType = "₹"; // default flat
  double subtotal = 0;
  double discount = 0;
  double finalTotal = 0;

  @override
  void initState() {
    super.initState();
    calculateTotals();
  }

  void calculateTotals() {
    subtotal = widget.items.fold(0, (sum, item) {
      return sum + (item.price * item.quantity);
    });

    if (discountType == "%") {
      discount =
          (subtotal * (double.tryParse(_discountController.text) ?? 0)) / 100;
    } else {
      discount = double.tryParse(_discountController.text) ?? 0;
    }

    finalTotal = subtotal - discount;
    if (finalTotal < 0) finalTotal = 0;
  }

  void _onDiscountChanged(String value) {
    setState(() {
      calculateTotals();
    });
  }

  void _onDiscountTypeChanged(String? value) {
    if (value == null) return;
    setState(() {
      discountType = value;
      calculateTotals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MandalaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Billing Summary")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Customer: ${widget.customerName}",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "Phone: ${widget.phoneNumber}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              const Text(
                "Items:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        "Qty: ${item.quantity}  •  ₹${item.price}",
                      ),
                      trailing: Text(
                        "₹${(item.price * item.quantity).toStringAsFixed(2)}",
                      ),
                    );
                  },
                ),
              ),

              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      onChanged: _onDiscountChanged,
                      decoration: const InputDecoration(
                        labelText: "Discount",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: discountType,
                    onChanged: _onDiscountTypeChanged,
                    items: const [
                      DropdownMenuItem(value: "₹", child: Text("₹ Flat")),
                      DropdownMenuItem(value: "%", child: Text("% Percent")),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text("Subtotal: ₹${subtotal.toStringAsFixed(2)}"),
              Text("Discount: ₹${discount.toStringAsFixed(2)}"),
              Text(
                "Final Total: ₹${finalTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text("Print Bill"),
                  onPressed: () async {
                    final billItems = widget.items
                        .map(
                          (item) => BillItem(
                            productId: item.productId,
                            name: item.name,
                            quantity: item.quantity,
                            price: item.price,
                            totalPrice: item.total,
                          ),
                        )
                        .toList();

                    final currentBill = Bill(
                      customerName: widget.customerName,
                      phone: widget.phoneNumber,
                      date: DateTime.now(),
                      subtotal: subtotal,
                      discount: discount,
                      total: finalTotal,
                    );

                    final db = DatabaseHelper.instance;

                    // 1. Save bill + items to DB
                    final billId = await db.insertBill(currentBill, billItems);

                    // 2. Fetch saved bill with correct auto ID (if needed)
                    final savedBill = currentBill.copyWith(id: billId);

                    // 3. Generate and print PDF
                    await generateBillPdf(savedBill, billItems);

                    // 4. (Optional) Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Bill #${billId + 1230} saved and ready to print!',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
