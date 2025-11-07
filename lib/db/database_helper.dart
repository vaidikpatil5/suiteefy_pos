// lib/db/database_helper.dart
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/product.dart';
import '../models/bill.dart';
import '../models/bill_item.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos_app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE inventory (
      product_id TEXT PRIMARY KEY,
      name TEXT,
      category TEXT,
      price REAL,
      stock INTEGER,
      variant TEXT
    )
    ''');
    await db.execute('''
    CREATE TABLE bills (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      customer_name TEXT,
      phone TEXT,
      subtotal REAL,
      discount REAL,
      total REAL
    )
    ''');
    await db.execute('''
    CREATE TABLE bill_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      bill_id INTEGER,
      product_id TEXT,
      name TEXT,
      quantity INTEGER,
      price REAL,
      total_price REAL,
      FOREIGN KEY (bill_id) REFERENCES bills (id)
    )
    ''');
  }

  // PRODUCT CRUD
  Future<void> insertProduct(Product p) async {
    final db = await instance.database;
    await db.insert(
      'inventory',
      p.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Product?> getProductById(String productId) async {
    final db = await instance.database;
    final maps = await db.query(
      'inventory',
      where: 'product_id = ? COLLATE NOCASE',
      whereArgs: [productId.trim()],
    );
    if (maps.isNotEmpty) return Product.fromMap(maps.first);
    return null;
  }

  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query('inventory', orderBy: 'name');
    return result.map((m) => Product.fromMap(m)).toList();
  }

  Future<List<Product>> searchProductsByName(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'inventory',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name',
    );
    return result.map((m) => Product.fromMap(m)).toList();
  }

  Future<int> updateProductStock(String productId, int newStock) async {
    final db = await instance.database;
    return await db.update(
      'inventory',
      {'stock': newStock},
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  // BILL CRUD
  Future<int> insertBill(Bill bill, List<BillItem> items) async {
    final db = await instance.database;
    return await db.transaction<int>((txn) async {
      final billId = await txn.insert('bills', bill.toMap());
      for (var it in items) {
        final map = it.toMap();
        map['bill_id'] = billId;
        await txn.insert('bill_items', map);
        // reduce stock
        final prod = await txn.query(
          'inventory',
          where: 'product_id = ?',
          whereArgs: [it.productId],
        );
        if (prod.isNotEmpty) {
          final currentStock = prod.first['stock'] as int;
          final newStock = currentStock - it.quantity;
          await txn.update(
            'inventory',
            {'stock': newStock},
            where: 'product_id = ?',
            whereArgs: [it.productId],
          );
        }
      }
      return billId;
    });
  }

  Future<List<Bill>> getAllBills() async {
    final db = await instance.database;
    final rows = await db.query('bills', orderBy: 'date DESC');
    return rows.map((r) => Bill.fromMap(r)).toList();
  }

  Future<List<BillItem>> getItemsForBill(int billId) async {
    final db = await instance.database;
    final rows = await db.query(
      'bill_items',
      where: 'bill_id = ?',
      whereArgs: [billId],
    );
    return rows.map((r) => BillItem.fromMap(r)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
