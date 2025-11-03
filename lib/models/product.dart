// lib/models/product.dart
class Product {
  final String productId; // e.g., PID001 (PRIMARY KEY)
  final String name;
  final String category;
  final double price;
  final int stock;
  final String variant; // optional

  Product({
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.variant = '',
  });

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        productId: map['product_id'] as String,
        name: map['name'] as String,
        category: map['category'] as String? ?? '',
        price: (map['price'] as num).toDouble(),
        stock: (map['stock'] as int?) ?? 0,
        variant: map['variant'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'product_id': productId,
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
        'variant': variant,
      };
}
