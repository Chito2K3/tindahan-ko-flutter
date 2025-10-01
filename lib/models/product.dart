import '../utils/theme.dart';

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
  final bool isBatchSelling;
  final int? batchQuantity;
  final double? batchPrice;

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
    this.isBatchSelling = false,
    this.batchQuantity,
    this.batchPrice,
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
    'isBatchSelling': isBatchSelling,
    'batchQuantity': batchQuantity,
    'batchPrice': batchPrice,
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
    isBatchSelling: json['isBatchSelling'] ?? false,
    batchQuantity: json['batchQuantity'],
    batchPrice: json['batchPrice']?.toDouble(),
  );

  bool get isLowStock => stock <= reorderLevel;
  
  double getPriceForQuantity(int quantity) {
    if (!isBatchSelling || batchQuantity == null || batchPrice == null) {
      return price * quantity;
    }
    
    // For batch-only selling (no individual price)
    if (price == 0.0) {
      final batches = quantity ~/ batchQuantity!;
      final remainder = quantity % batchQuantity!;
      // Calculate individual price from batch price
      final individualPrice = batchPrice! / batchQuantity!;
      return (batches * batchPrice!) + (remainder * individualPrice);
    }
    
    // For mixed selling (both individual and batch pricing)
    final batches = quantity ~/ batchQuantity!;
    final remainder = quantity % batchQuantity!;
    
    return (batches * batchPrice!) + (remainder * price);
  }
  
  String get displayPrice {
    if (!isBatchSelling || batchQuantity == null || batchPrice == null) {
      return AppTheme.formatCurrency(price);
    }
    
    // For batch-only selling
    if (price == 0.0) {
      final individualPrice = batchPrice! / batchQuantity!;
      return '${batchQuantity}pcs for ${AppTheme.formatCurrency(batchPrice!)} (${AppTheme.formatCurrency(individualPrice)}/pc)';
    }
    
    // For mixed selling
    return '${AppTheme.formatCurrency(price)}/pc or ${batchQuantity}pcs for ${AppTheme.formatCurrency(batchPrice!)}';
  }
}