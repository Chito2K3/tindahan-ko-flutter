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
  int loosePieces; // Loose pieces available
  int fullPacks; // Full packs available
  bool autoOpenPack; // Auto-open pack when loose pieces run out

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
    this.loosePieces = 0,
    this.fullPacks = 0,
    this.autoOpenPack = true,
  }) {
    if (isCigarette) {
      // For cigarettes, calculate packs and loose pieces from total stock
      fullPacks = stock ~/ (piecesPerPack ?? 20);
      loosePieces = stock % (piecesPerPack ?? 20);
    }
  }

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
    'loosePieces': loosePieces,
    'fullPacks': fullPacks,
    'autoOpenPack': autoOpenPack,
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
    loosePieces: json['loosePieces'] ?? 0,
    fullPacks: json['fullPacks'] ?? 0,
    autoOpenPack: json['autoOpenPack'] ?? true,
  );

  bool get isLowStock => (isCigarette || category == 'cigarettes') ? fullPacks <= reorderLevel : stock <= reorderLevel;
  
  int get totalPieces => (isCigarette || category == 'cigarettes') ? (fullPacks * (piecesPerPack ?? 20)) + loosePieces : stock;
  
  bool canSellPieces(int quantity) {
    if (!isCigarette && category != 'cigarettes') return stock >= quantity;
    if (loosePieces >= quantity) return true;
    if (autoOpenPack && fullPacks > 0) {
      int neededFromPacks = quantity - loosePieces;
      int packsNeeded = (neededFromPacks / (piecesPerPack ?? 20)).ceil();
      return fullPacks >= packsNeeded;
    }
    return false;
  }
  
  bool canSellPacks(int quantity) {
    return (isCigarette || category == 'cigarettes') ? fullPacks >= quantity : stock >= (quantity * (piecesPerPack ?? 20));
  }
  
  void sellPieces(int quantity) {
    if (!isCigarette && category != 'cigarettes') {
      stock -= quantity;
      return;
    }
    
    if (loosePieces >= quantity) {
      loosePieces -= quantity;
    } else if (autoOpenPack && fullPacks > 0) {
      int remaining = quantity - loosePieces;
      loosePieces = 0;
      
      while (remaining > 0 && fullPacks > 0) {
        fullPacks--;
        loosePieces += (piecesPerPack ?? 20);
        int toTake = remaining > loosePieces ? loosePieces : remaining;
        loosePieces -= toTake;
        remaining -= toTake;
      }
    }
    stock = (fullPacks * (piecesPerPack ?? 20)) + loosePieces;
  }
  
  void sellPacks(int quantity) {
    if (!isCigarette && category != 'cigarettes') {
      stock -= quantity * (piecesPerPack ?? 20);
      return;
    }
    
    fullPacks -= quantity;
    stock = (fullPacks * (piecesPerPack ?? 20)) + loosePieces;
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
      return '${fullPacks} packs + ${loosePieces} pcs';
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