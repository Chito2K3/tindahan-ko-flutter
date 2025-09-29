class Product {
  final String id;
  final String name;
  final double price;
  int stock;
  final String category;
  final String emoji;
  final int reorderLevel;
  final bool hasBarcode;
  final String? barcode;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.emoji,
    required this.reorderLevel,
    required this.hasBarcode,
    this.barcode,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'stock': stock,
    'category': category,
    'emoji': emoji,
    'reorderLevel': reorderLevel,
    'hasBarcode': hasBarcode,
    'barcode': barcode,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    price: json['price'].toDouble(),
    stock: json['stock'],
    category: json['category'],
    emoji: json['emoji'],
    reorderLevel: json['reorderLevel'],
    hasBarcode: json['hasBarcode'],
    barcode: json['barcode'],
  );

  bool get isLowStock => stock <= reorderLevel;
}