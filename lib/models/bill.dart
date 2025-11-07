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
    String? phone,
    double? subtotal,
    double? discount,
    double? total,
  }) {
    return Bill(
      id: id ?? this.id,
      date: date ?? this.date,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
    );
  }
}
