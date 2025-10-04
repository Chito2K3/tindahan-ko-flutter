import '../utils/theme.dart';

class Product {
  final String id;
  final String name;
  final double price; // Price per piece for cigarettes
  int stock; // Total pieces for cigarettes, regular stock for others
  final String category;
  final String emoji;
  final int reorderLevel; // In packs for cigarettes
  final bool hasBarcode;
  final String? barcode;
  final bool isBatchSelling;
  final int? batchQuantity;
  final double? batchPrice;
  final bool isCigarette;
  final int? piecesPerPack; // Always 20 for cigarettes
  final double? packPrice;
  int packStock; // Pack stock only - this is what we track for cigarettes
  int _stickBuffer = 0; // Internal stick buffer (loaded from database)

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
    this.isCigarette = false,
    this.piecesPerPack = 20,
    this.packPrice,
    this.packStock = 0,
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
    'isCigarette': isCigarette,
    'piecesPerPack': piecesPerPack,
    'packPrice': packPrice,
    'packStock': packStock,
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
    isCigarette: json['isCigarette'] ?? false,
    piecesPerPack: json['piecesPerPack'] ?? 20,
    packPrice: json['packPrice']?.toDouble(),
    packStock: json['packStock'] ?? 0,
  );

  bool get isLowStock => (isCigarette || category == 'cigarettes') ? packStock <= reorderLevel : stock <= reorderLevel;
  
  int get totalPieces => (isCigarette || category == 'cigarettes') ? (_stickBuffer + (packStock * (piecesPerPack ?? 20))) : stock;
  
  int get stickBuffer => _stickBuffer;
  
  void setStickBuffer(int buffer) {
    _stickBuffer = buffer;
  }
  
  bool canSellSticks(int quantity) {
    if (!isCigarette && category != 'cigarettes') return stock >= quantity;
    // Check if we have enough sticks (from buffer + unopened packs)
    int availableSticks = _stickBuffer + (packStock * (piecesPerPack ?? 20));
    return availableSticks >= quantity;
  }
  
  bool canSellPacks(int quantity) {
    return (isCigarette || category == 'cigarettes') ? packStock >= quantity : stock >= (quantity * (piecesPerPack ?? 20));
  }
  
  void sellSticks(int quantity) {
    if (!isCigarette && category != 'cigarettes') {
      stock -= quantity;
      return;
    }
    
    int remaining = quantity;
    
    // First, use sticks from buffer
    if (_stickBuffer >= remaining) {
      _stickBuffer -= remaining;
      return;
    }
    
    // Use all buffer sticks first
    remaining -= _stickBuffer;
    _stickBuffer = 0;
    
    // Open packs as needed - deduct pack immediately when opened
    while (remaining > 0 && packStock > 0) {
      packStock--; // Deduct pack from inventory immediately
      
      if (remaining >= (piecesPerPack ?? 20)) {
        // Need entire pack or more
        remaining -= (piecesPerPack ?? 20);
      } else {
        // Need partial pack - put remainder in buffer
        _stickBuffer = (piecesPerPack ?? 20) - remaining;
        remaining = 0;
      }
    }
  }
  
  void sellPacks(int quantity) {
    if (!isCigarette && category != 'cigarettes') {
      stock -= quantity * (piecesPerPack ?? 20);
      return;
    }
    
    packStock -= quantity;
  }
  
  double getPriceForQuantity(int quantity, {bool isPackMode = false}) {
    if ((isCigarette || category == 'cigarettes') && packPrice != null) {
      return isPackMode ? quantity * packPrice! : quantity * price;
    }
    
    if (!isBatchSelling || batchQuantity == null || batchPrice == null) {
      return price * quantity;
    }
    
    if (price == 0.0) {
      final batches = quantity ~/ batchQuantity!;
      final remainder = quantity % batchQuantity!;
      final individualPrice = batchPrice! / batchQuantity!;
      return (batches * batchPrice!) + (remainder * individualPrice);
    }
    
    final batches = quantity ~/ batchQuantity!;
    final remainder = quantity % batchQuantity!;
    return (batches * batchPrice!) + (remainder * price);
  }
  
  String get displayPrice {
    if ((isCigarette || category == 'cigarettes') && packPrice != null) {
      return '${AppTheme.formatCurrency(price)}/pc • ${AppTheme.formatCurrency(packPrice!)}/pack';
    }
    
    if (!isBatchSelling || batchQuantity == null || batchPrice == null) {
      return AppTheme.formatCurrency(price);
    }
    
    if (price == 0.0) {
      final individualPrice = batchPrice! / batchQuantity!;
      return '${batchQuantity}pcs for ${AppTheme.formatCurrency(batchPrice!)} (${AppTheme.formatCurrency(individualPrice)}/pc)';
    }
    
    return '${AppTheme.formatCurrency(price)}/pc or ${batchQuantity}pcs for ${AppTheme.formatCurrency(batchPrice!)}';
  }
  
  String get stockDisplay {
    if (isCigarette || category == 'cigarettes') {
      return '${packStock} packs${_stickBuffer > 0 ? ' + ${_stickBuffer} sticks' : ''}';
    }
    return stock.toString();
  }
}

enum CigaretteUnit { piece, pack }

class CigaretteCartItem {
  final Product product;
  int pieceQuantity;
  int packQuantity;
  
  CigaretteCartItem({
    required this.product,
    this.pieceQuantity = 0,
    this.packQuantity = 0,
  });
  
  double get totalPrice => 
    (pieceQuantity * product.price) + (packQuantity * (product.packPrice ?? 0));
  
  int get totalPieces => pieceQuantity + (packQuantity * (product.piecesPerPack ?? 20));
  
  bool get isEmpty => pieceQuantity == 0 && packQuantity == 0;
  
  String get displayText {
    List<String> parts = [];
    if (packQuantity > 0) parts.add('${packQuantity} pack${packQuantity > 1 ? 's' : ''}');
    if (pieceQuantity > 0) parts.add('${pieceQuantity} pc${pieceQuantity > 1 ? 's' : ''}');
    return parts.join(' + ');
  }
}