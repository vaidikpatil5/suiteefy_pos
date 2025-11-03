// lib/utils/pdf_helper.dart

import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../models/bill.dart';

Future<void> generateBillPdf(Bill bill, List<BillItem> items) async {
  final pdf = pw.Document();
  final date = DateFormat('dd/MM/yyyy – hh:mm a').format(bill.date);
  final totalItems = items.length;
  final hasDiscount = bill.discount > 0;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(58 * 2.83, double.infinity, marginAll: 5),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // HEADER
            pw.Text(
              'SUITEEFY',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'everything that suits your style',
              style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Contact: 9399731145', style: pw.TextStyle(fontSize: 8)),
            pw.Divider(thickness: 0.5),
            pw.Text(
              'Bill No: ${bill.id! + 1230}',
              style: pw.TextStyle(fontSize: 8),
            ),
            pw.Text('Date: $date', style: pw.TextStyle(fontSize: 8)),
            pw.SizedBox(height: 4),
            pw.Text(
              'Customer: ${bill.customerName}',
              style: pw.TextStyle(fontSize: 8),
            ),
            pw.Divider(thickness: 0.8),

            // ITEM TABLE
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'S.No',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Product / ID',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Price',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.Divider(thickness: 0.5),
            ...items.asMap().entries.map((entry) {
              final i = entry.key + 1;
              final it = entry.value;
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('$i', style: const pw.TextStyle(fontSize: 8)),
                  pw.Expanded(
                    child: pw.Text(
                      '${it.name} [${it.productId}]',
                      style: const pw.TextStyle(fontSize: 8),
                      textAlign: pw.TextAlign.left,
                    ),
                  ),
                  pw.Text(
                    '₹${it.totalPrice.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              );
            }),

            pw.Divider(thickness: 0.8),
            // TOTALS
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Items: $totalItems',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    'Subtotal: ₹${bill.subtotal.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                  if (hasDiscount)
                    pw.Text(
                      'Discount: ₹${bill.discount.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 8),
                    ),
                  pw.Text(
                    'Grand Total: ₹${bill.total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.Divider(thickness: 0.8),

            // FOOTER
            pw.SizedBox(height: 4),
            pw.Text(
              'Thank you for shopping with us!',
              style: pw.TextStyle(fontSize: 8),
            ),
            pw.Text('Visit again soon!', style: pw.TextStyle(fontSize: 8)),
          ],
        );
      },
    ),
  );

  // 🔹 Open Print Dialog Immediately
  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
