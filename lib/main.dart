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

  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleDown;
  late Animation<Offset> _logoSlideUp;
  late Animation<Offset> _bottomSlideUp;

  @override
  void initState() {
    super.initState();
    loadProducts();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.33, curve: Curves.easeIn),
    );
    _scaleDown = Tween<double>(begin: 1.2, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 1.0, curve: Curves.easeInOut),
      ),
    );

    _logoSlideUp = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.33, 1.0, curve: Curves.easeInOut),
          ),
        );

    _bottomSlideUp = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.33, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.forward();
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
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBDD), // matches your cream-beige tone
      body: Stack(
        children: [
          /// --- Center Logo Animation ---
          Align(
            alignment: Alignment.center,
            child: SlideTransition(
              position: _logoSlideUp,
              child: FadeTransition(
                opacity: _fadeIn,
                child: ScaleTransition(
                  scale: _scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/suiteefy-iconsq.png', height: 150),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// --- Bottom Block Animation ---
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _bottomSlideUp,
              child: Container(
                height: height * 0.6,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 40,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.bodyText, // your dark brown
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 30,
                        childAspectRatio: 1,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildMenuButton('Custom New Bill', () {}),
                          _buildMenuButton('Create New Bill', () {
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
                                builder: (context) => const BillHistoryScreen(),
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
        backgroundColor: const Color(0xFFF5EBDD),
        foregroundColor: Colors.brown.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.all(12),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
