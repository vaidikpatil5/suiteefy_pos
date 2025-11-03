// lib/models/bill.dart
class Bill {
  int? id; // autoincrement in DB
  final DateTime date;
  final String? customerName;
  final String? phone;
  final double subtotal;
  final double discount;
  final double total;

  Bill({
    this.id,
    required this.date,
    this.customerName,
    this.phone,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'customer_name': customerName,
        'phone': phone,
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
      };

  factory Bill.fromMap(Map<String, dynamic> map) => Bill(
        id: map['id'] as int,
        date: DateTime.parse(map['date'] as String),
        customerName: map['customer_name'] as String?,
        phone: map['phone'] as String?,
        subtotal: (map['subtotal'] as num).toDouble(),
        discount: (map['discount'] as num).toDouble(),
        total: (map['total'] as num).toDouble(),
      );

      Bill copyWith({
  int? id,
  DateTime? date,
  String? customerName,
  double? subtotal,
  double? discount,
  double? total,
}) {
  return Bill(
    id: id ?? this.id,
    date: date ?? this.date,
    customerName: customerName ?? this.customerName,
    subtotal: subtotal ?? this.subtotal,
    discount: discount ?? this.discount,
    total: total ?? this.total,
  );
}


}

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
