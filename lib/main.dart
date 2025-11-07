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
  late Animation<double> _moveUp;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    loadProducts();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _moveUp = Tween<double>(begin: 0, end: -180).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _scale = Tween<double>(begin: 1, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeInOut),
      ),
    );

    // ✅ Start animation after first frame is visible
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(
        const AssetImage('assets/suiteefy_logo.png'),
        context,
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _controller.forward();
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 204, 169),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ---- Top Mandala behind logo ----
          FadeTransition(
            opacity: _fadeIn,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: height * 0.12),
                child: Opacity(
                  opacity: 0.75,
                  child: Image.asset(
                    'assets/mandala_top.png',
                    width: width * 0.9,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // ---- Animated logo ----
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.4 + _moveUp.value,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.scale(scale: _scale.value, child: child),
                ),
              );
            },
            child: Image.asset('assets/suiteefy-iconsq.png', height: 150),
          ),
          // ---- Bottom Mandala behind the brown block ----
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final slideUp =
                  Tween<double>(
                    begin: height * 0.6, // off-screen
                    end: 0, // final position
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(
                        0.7,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  );

              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(0, slideUp.value),
                  child: Container(
                    height: height * 0.6,
                    decoration: const BoxDecoration(
                      color: const Color.fromARGB(250, 51, 33, 22),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(45),
                        topRight: Radius.circular(45),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // --- Mandala blended inside the brown box ---
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Opacity(
                            opacity: 0.45, // subtle background
                            child: Image.asset(
                              'assets/mandala_bottom.png',
                              width: width * 0.8,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // --- Foreground content ---
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 35,
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
                                          builder: (context) =>
                                              const NewBillScreen(),
                                        ),
                                      );
                                    }),
                                    _buildMenuButton('Settings', () {}),
                                    _buildMenuButton('Billing History', () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const BillHistoryScreen(),
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
                                      backgroundColor: const Color.fromARGB(
                                        250,
                                        220,
                                        200,
                                        175,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: loading
                                        ? const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          )
                                        : const Icon(
                                            Icons.add,
                                            color: const Color.fromARGB(
                                              250,
                                              51,
                                              33,
                                              22,
                                            ),
                                            size: 30,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(250, 220, 200, 175),
        foregroundColor: const Color.fromARGB(250, 51, 33, 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
