import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models/product.dart';
import 'utils/csv_importer.dart';
import 'bill_history_screen.dart';
import 'new_bill_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUITEEFY POS',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Product> products = [];
  bool loading = false;
  bool _showButtons = false;
  late AnimationController _controller;
  late Animation<double> _logoSizeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    loadProducts();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _logoSizeAnimation = Tween<double>(
      begin: 1,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showButtons = true;
        _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: _showButtons
                ? MediaQuery.of(context).size.height * 0.1
                : MediaQuery.of(context).size.height / 2 - 100,
            left: 0,
            right: 0,
            child: Center(
              child: ScaleTransition(
                scale: _logoSizeAnimation,

                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset('assets/suiteefy-iconsq.png', height: 150),
                ),
              ),
            ),
          ),

          if (_showButtons)
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.60,
                  padding: const EdgeInsets.all(40),
                  decoration: const BoxDecoration(
                    color: AppTheme.bodyText,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 30,
                          childAspectRatio: 1,
                          children: [
                            _buildMenuButton('Custom New Bill', () {}),
                            _buildMenuButton('New Bill', () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NewBillScreen(),
                                ),
                              );
                            }),
                            _buildMenuButton('Settings', () {}),
                            _buildMenuButton('Billing History', () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BillHistoryScreen(),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: 60,
                          height: 65,
                          child: ElevatedButton(
                            onPressed: handleImport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lilacTaupe,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: loading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
