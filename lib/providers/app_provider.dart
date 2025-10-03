import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<CartItem> _cart = [];
  List<CigaretteCartItem> _cigaretteCart = [];
  Map<String, dynamic> _storeInfo = {};
  bool _isLoading = false;
  List<Sale> _sales = [];
  
  List<Product> get products => _products;
  List<CartItem> get cart => _cart;
  List<CigaretteCartItem> get cigaretteCart => _cigaretteCart;
  Map<String, dynamic> get storeInfo => _storeInfo;
  bool get isLoading => _isLoading;
  List<Sale> get sales => _sales;
  
  double get cartTotal => 
    _cart.fold(0, (sum, item) => sum + item.product.getPriceForQuantity(item.quantity, isPackMode: item.isPackMode)) +
    _cigaretteCart.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.isLowStock).length;
  

  
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _products = await DatabaseService.getAllProducts();
      _sales = await DatabaseService.getAllSales();
      
      // If no products exist, load sample data
      if (_products.isEmpty) {
        await _loadSampleData();
      }
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _loadSampleData() async {
    final sampleProducts = [
      Product(
        id: 'p1',
        name: 'Skyflakes Crackers',
        price: 15.00,
        stock: 50,
        category: 'snacks',
        emoji: '🍪',
        reorderLevel: 10,
        hasBarcode: true,
        barcode: '4800016644931',
      ),
      Product(
        id: 'p6',
        name: 'Mentos Candy',
        price: 2.00,
        stock: 100,
        category: 'candies',
        emoji: '🍬',
        reorderLevel: 20,
        hasBarcode: false,
        isBatchSelling: true,
        batchQuantity: 3,
        batchPrice: 5.00,
      ),
      Product(
        id: 'p2',
        name: 'Coca Cola 355ml',
        price: 25.00,
        stock: 30,
        category: 'drinks',
        emoji: '🥤',
        reorderLevel: 5,
        hasBarcode: true,
        barcode: '4902430735063',
      ),
      Product(
        id: 'p3',
        name: 'Lucky Me Pancit Canton',
        price: 12.50,
        stock: 75,
        category: 'snacks',
        emoji: '🍜',
        reorderLevel: 15,
        hasBarcode: true,
        barcode: '4800016001000',
      ),
      Product(
        id: 'p4',
        name: 'Tide Detergent Powder',
        price: 8.00,
        stock: 20,
        category: 'household',
        emoji: '🧽',
        reorderLevel: 8,
        hasBarcode: false,
      ),
      Product(
        id: 'p5',
        name: 'Colgate Toothpaste',
        price: 45.00,
        stock: 15,
        category: 'personal',
        emoji: '🦷',
        reorderLevel: 5,
        hasBarcode: true,
        barcode: '8850006330012',
      ),
      Product(
        id: 'p7',
        name: 'Marlboro Red',
        price: 6.50,
        stock: 200,
        category: 'cigarette',
        emoji: '🚬',
        reorderLevel: 40,
        hasBarcode: true,
        barcode: '1234567890123',
        isCigarette: true,
        piecesPerPack: 20,
        packPrice: 130.00,
        loosePieces: 0,
        fullPacks: 10,
        autoOpenPack: true,
      ),
    ];
    
    for (final product in sampleProducts) {
      await DatabaseService.insertProduct(product);
    }
    
    _products = sampleProducts;
  }
  
  Product? findProductByBarcode(String barcode) {
    return _products.where((p) => p.barcode == barcode).firstOrNull;
  }
  
  void addToCart(Product product) {
    if (product.isCigarette) {
      addCigaretteToCart(product, CigaretteUnit.piece, 1);
      return;
    }
    
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      final increment = product.isBatchSelling ? product.batchQuantity! : 1;
      if (_cart[existingIndex].quantity + increment <= product.stock) {
        _cart[existingIndex].quantity += increment;
      }
    } else {
      final initialQuantity = product.isBatchSelling ? product.batchQuantity! : 1;
      _cart.add(CartItem(product: product, quantity: initialQuantity, isPackMode: false));
    }
    notifyListeners();
  }
  
  void addCigaretteToCart(Product product, CigaretteUnit unit, int quantity) {
    if (!product.isCigarette) return;
    
    final existingIndex = _cigaretteCart.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      if (unit == CigaretteUnit.pack) {
        if (product.canSellPacks(_cigaretteCart[existingIndex].packQuantity + quantity)) {
          _cigaretteCart[existingIndex].packQuantity += quantity;
        }
      } else {
        if (product.canSellPieces(_cigaretteCart[existingIndex].pieceQuantity + quantity)) {
          _cigaretteCart[existingIndex].pieceQuantity += quantity;
        }
      }
    } else {
      final item = CigaretteCartItem(product: product);
      if (unit == CigaretteUnit.pack && product.canSellPacks(quantity)) {
        item.packQuantity = quantity;
      } else if (unit == CigaretteUnit.piece && product.canSellPieces(quantity)) {
        item.pieceQuantity = quantity;
      }
      if (!item.isEmpty) {
        _cigaretteCart.add(item);
      }
    }
    notifyListeners();
  }
  
  void updateCigaretteQuantity(int index, CigaretteUnit unit, int change) {
    if (index >= _cigaretteCart.length) return;
    
    final item = _cigaretteCart[index];
    if (unit == CigaretteUnit.pack) {
      final newQuantity = item.packQuantity + change;
      if (newQuantity <= 0) {
        item.packQuantity = 0;
      } else if (item.product.canSellPacks(newQuantity)) {
        item.packQuantity = newQuantity;
      }
    } else {
      final newQuantity = item.pieceQuantity + change;
      if (newQuantity <= 0) {
        item.pieceQuantity = 0;
      } else if (item.product.canSellPieces(newQuantity)) {
        item.pieceQuantity = newQuantity;
      }
    }
    
    if (item.isEmpty) {
      _cigaretteCart.removeAt(index);
    }
    notifyListeners();
  }
  
  void removeFromCart(int index) {
    _cart.removeAt(index);
    notifyListeners();
  }
  
  void updateCartQuantity(int index, int change) {
    final item = _cart[index];
    final newQuantity = item.quantity + change;
    
    if (newQuantity <= 0) {
      removeFromCart(index);
    } else if (newQuantity <= item.product.stock) {
      item.quantity = newQuantity;
      notifyListeners();
    }
  }
  
  void updateCartQuantityByIncrement(int index, int change, int increment) {
    final item = _cart[index];
    final actualIncrement = item.product.isCigarette && item.isPackMode ? item.product.piecesPerPack! : increment;
    final newQuantity = item.quantity + (change * actualIncrement);
    
    if (newQuantity <= 0) {
      removeFromCart(index);
    } else if (newQuantity <= item.product.stock) {
      item.quantity = newQuantity;
      notifyListeners();
    }
  }
  
  void clearCart() {
    _cart.clear();
    _cigaretteCart.clear();
    notifyListeners();
  }
  
  void toggleCigaretteMode(int index) {
    if (index < _cart.length && _cart[index].product.isCigarette) {
      _cart[index].isPackMode = !_cart[index].isPackMode;
      // Adjust quantity based on mode
      if (_cart[index].isPackMode) {
        // Convert pieces to packs
        _cart[index].quantity = (_cart[index].quantity / _cart[index].product.piecesPerPack!).ceil();
      } else {
        // Convert packs to pieces
        _cart[index].quantity = _cart[index].quantity * _cart[index].product.piecesPerPack!;
      }
      notifyListeners();
    }
  }
  
  Future<void> completeSale() async {
    try {
      // Create sale record
      final saleId = 'sale_${DateTime.now().millisecondsSinceEpoch}';
      final saleItems = <SaleItem>[];
      
      // Add regular cart items
      saleItems.addAll(_cart.map((cartItem) => SaleItem(
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        quantity: cartItem.quantity,
        price: cartItem.product.getPriceForQuantity(1, isPackMode: cartItem.isPackMode),
      )));
      
      // Add cigarette cart items
      for (final cigItem in _cigaretteCart) {
        if (cigItem.packQuantity > 0) {
          saleItems.add(SaleItem(
            productId: cigItem.product.id,
            productName: '${cigItem.product.name} (Pack)',
            quantity: cigItem.packQuantity,
            price: cigItem.product.packPrice ?? 0,
          ));
        }
        if (cigItem.pieceQuantity > 0) {
          saleItems.add(SaleItem(
            productId: cigItem.product.id,
            productName: '${cigItem.product.name} (Piece)',
            quantity: cigItem.pieceQuantity,
            price: cigItem.product.price,
          ));
        }
      }
      
      final sale = Sale(
        id: saleId,
        date: DateTime.now(),
        total: cartTotal,
        items: saleItems,
      );
      
      // Save sale to database
      await DatabaseService.insertSale(sale);
      
      // Update stock in database and memory
      for (final cartItem in _cart) {
        final product = _products.firstWhere((p) => p.id == cartItem.product.id);
        product.stock -= cartItem.quantity;
        await DatabaseService.updateProduct(product);
      }
      
      // Update cigarette stock
      for (final cigItem in _cigaretteCart) {
        final product = _products.firstWhere((p) => p.id == cigItem.product.id);
        if (cigItem.packQuantity > 0) {
          product.sellPacks(cigItem.packQuantity);
        }
        if (cigItem.pieceQuantity > 0) {
          product.sellPieces(cigItem.pieceQuantity);
        }
        await DatabaseService.updateProduct(product);
      }
      
      // Reload sales data
      _sales = await DatabaseService.getAllSales();
      
      // Clear cart
      clearCart();
      notifyListeners();
    } catch (e) {
      print('Error completing sale: $e');
      rethrow;
    }
  }
  
  Future<void> addProduct(Product product) async {
    try {
      await DatabaseService.insertProduct(product);
      _products.add(product);
      notifyListeners();
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }
  
  Future<void> updateProduct(Product updatedProduct) async {
    try {
      await DatabaseService.updateProduct(updatedProduct);
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }
  
  Future<void> deleteProduct(String productId) async {
    try {
      await DatabaseService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      // Also remove from cart if present
      _cart.removeWhere((item) => item.product.id == productId);
      notifyListeners();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }
}

class CartItem {
  final Product product;
  int quantity;
  bool isPackMode;
  
  CartItem({required this.product, required this.quantity, this.isPackMode = false});
}