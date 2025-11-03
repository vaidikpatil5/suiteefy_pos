import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models/product.dart';
import 'utils/csv_importer.dart';
import 'bill_history_screen.dart';
import 'new_bill_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Manager',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final db = DatabaseHelper.instance;
    final all = await db.getAllProducts();
    setState(() => products = all);
  }

  Future<void> handleImport() async {
    setState(() => loading = true);
    final message = await CSVImporter.importCSV();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    await loadProducts();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Manager'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadProducts),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: handleImport,
        child: const Icon(Icons.upload_file),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewBillScreen(),
                  ),
                );
              },
              child: const Text("Create New Bill"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BillHistoryScreen()),
                );
              },
              child: const Text('Bill History'),
            ),
          ],
        ),
      ),
    );
  }
}
