import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/bill.dart';
import '../db/database_helper.dart';
import '../screens/bill_detail_screen.dart';

class BillHistoryScreen extends StatefulWidget {
  const BillHistoryScreen({Key? key}) : super(key: key);

  @override
  _BillHistoryScreenState createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  final db = DatabaseHelper.instance;
  List<Bill> bills = [];

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    final data = await db.getAllBills(); // You’ll add this in DB helper
    setState(() {
      bills = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing History'),
      ),
      body: bills.isEmpty
          ? const Center(child: Text('No bills found.'))
          : ListView.builder(
              itemCount: bills.length,
              itemBuilder: (context, index) {
                final bill = bills[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                      bill.customerName ?? 'Unknown Customer',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Bill No: ${bill.id! + 1230} • Date: ${DateFormat('dd MMM yyyy').format(bill.date)}',
                    ),
                    trailing: Text(
                      '₹${bill.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillDetailScreen(bill: bill),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
