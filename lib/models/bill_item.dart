class BillItem {
  int? id;
  int? billId; // FK
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final double totalPrice;

  BillItem({
    this.id,
    this.billId,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() => {
    'bill_id': billId,
    'product_id': productId,
    'name': name,
    'quantity': quantity,
    'price': price,
    'total_price': totalPrice,
  };

  factory BillItem.fromMap(Map<String, dynamic> map) => BillItem(
    id: map['id'] as int?,
    billId: map['bill_id'] as int?,
    productId: map['product_id'] as String,
    name: map['name'] as String,
    quantity: (map['quantity'] as int),
    price: (map['price'] as num).toDouble(),
    totalPrice: (map['total_price'] as num).toDouble(),
  );
}
