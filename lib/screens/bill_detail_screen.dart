import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../db/database_helper.dart';
import '../models/bill.dart';

class BillDetailScreen extends StatefulWidget {
  final Bill bill;
  const BillDetailScreen({super.key, required this.bill});

  @override
  _BillDetailScreenState createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  final db = DatabaseHelper.instance;
  List<BillItem> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final data = await db.getItemsForBill(widget.bill.id!);
    setState(() {
      items = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bill #${widget.bill.id! + 1230}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${widget.bill.customerName}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text('Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(widget.bill.date)}'),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No items found.'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text('Qty: ${item.quantity} × ₹${item.price}'),
                          trailing: Text('₹${(item.quantity * item.price).toStringAsFixed(2)}'),
                        );
                      },
                    ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: ₹${widget.bill.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
