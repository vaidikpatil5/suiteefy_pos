import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../db/database_helper.dart';
import '../models/product.dart';

class CSVImporter {
  static Future<String> importCSV() async {
    try {
      // Let user pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return 'No file selected';

      final filePath = result.files.single.path!;
      final file = File(filePath);

      final raw = await file.readAsString();
      final rows = const CsvToListConverter().convert(raw);

      if (rows.isEmpty) return 'Empty file';

      final db = DatabaseHelper.instance;

      // Assuming first row is header
      for (int i = 1; i < rows.length; i++) {
        final r = rows[i];

        // Defensive type handling
        final product = Product(
          productId: r[0].toString().trim(),
          name: r[1].toString().trim(),
          category: r.length > 2 ? r[2].toString().trim() : '',
          price: double.tryParse(r[3].toString()) ?? 0,
          stock: int.tryParse(r[4].toString()) ?? 0,
          variant: r.length > 5 ? r[5].toString().trim() : '',
        );

        await db.insertProduct(product);
      }

      return 'Import successful: ${rows.length - 1} products added';
    } catch (e) {
      return 'Error importing: $e';
    }
  }
}
