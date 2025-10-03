import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<CartItem> _cart = [];
  Map<String, dynamic> _storeInfo = {};
  bool _isLoading = false;
  List<Sale> _sales = [];
  
  List<Product> get products => _products;
  List<CartItem> get cart => _cart;
  Map<String, dynamic> get storeInfo => _storeInfo;
  bool get isLoading => _isLoading;
  List<Sale> get sales => _sales;
  
  double get cartTotal => _cart.fold(0.0, (sum, item) {
    if (item.product.isCigarette || item.product.category == 'cigarettes') {
      if (item.isPackMode) {
        return sum + (item.quantity * (item.product.packPrice ?? 0));
      } else {
        return sum + (item.quantity * item.product.price);
      }
    }
    return sum + item.product.getPriceForQuantity(item.quantity, isPackMode: item.isPackMode);
  });
  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.isLowStock).length;
  

  
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _products = await DatabaseService.getAllProducts();
      _sales = await DatabaseService.getAllSales();
      
      // Start with empty inventory for testing
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
        name: 'Winston',
        price: 10.00,
        stock: 400,
        category: 'cigarettes',
        emoji: '🚬',
        reorderLevel: 40,
        hasBarcode: true,
        barcode: '1234567890123',
        isCigarette: true,
        piecesPerPack: 20,
        packPrice: 190.00,
        loosePieces: 0,
        fullPacks: 20,
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
  
  void addToCart(Product product, {bool isPackMode = false}) {
    if (product.isCigarette || product.category == 'cigarettes') {
      // For cigarettes, find existing item with same mode
      final existingIndex = _cart.indexWhere((item) => 
        item.product.id == product.id && item.isPackMode == isPackMode);
      
      if (existingIndex >= 0) {
        // Add to existing cigarette cart item with same mode
        final existingItem = _cart[existingIndex];
        if (isPackMode) {
          if (existingItem.quantity + 1 <= product.fullPacks) {
            existingItem.quantity += 1;
          }
        } else {
          final totalAvailable = product.loosePieces + (product.fullPacks * 20);
          if (existingItem.quantity + 1 <= totalAvailable) {
            existingItem.quantity += 1;
          }
        }
      } else {
        // Create new cigarette cart item for this mode
        final newItem = CartItem(
          product: product, 
          quantity: 1, 
          isPackMode: isPackMode,
        );
        _cart.add(newItem);
      }
    } else {
      // Handle non-cigarette products
      final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
      
      if (existingIndex >= 0) {
        final increment = product.isBatchSelling ? product.batchQuantity! : 1;
        if (_cart[existingIndex].quantity + increment <= product.stock) {
          _cart[existingIndex].quantity += increment;
        }
      } else {
        final initialQuantity = product.isBatchSelling ? product.batchQuantity! : 1;
        _cart.add(CartItem(product: product, quantity: initialQuantity));
      }
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
  
  String? updateCartQuantityByIncrement(int index, int change, int increment) {
    final item = _cart[index];
    String? message;
    
    if (item.product.isCigarette || item.product.category == 'cigarettes') {
      // Handle cigarette quantity updates
      final newQuantity = item.quantity + change;
      
      if (newQuantity <= 0) {
        removeFromCart(index);
        return message;
      }
      
      if (item.isPackMode) {
        // Check pack stock
        final availablePacks = item.product.fullPacks;
        if (newQuantity > availablePacks) {
          message = 'We can only sell $availablePacks of ${item.product.name}.';
        } else {
          item.quantity = newQuantity;
        }
      } else {
        // Check piece stock and 19 limit
        if (newQuantity > 19) {
          message = '20 pieces = 1 pack. Switch to Pack Mode for more.';
        } else {
          final availablePieces = item.product.loosePieces;
          final totalAvailable = availablePieces + (item.product.fullPacks * 20);
          if (newQuantity > totalAvailable) {
            message = 'We can only sell $totalAvailable pieces of ${item.product.name}.';
          } else {
            item.quantity = newQuantity;
          }
        }
      }
    } else {
      // Handle non-cigarette products
      final actualIncrement = increment;
      final newQuantity = item.quantity + (change * actualIncrement);
      
      if (newQuantity <= 0) {
        removeFromCart(index);
      } else if (newQuantity <= item.product.stock) {
        item.quantity = newQuantity;
      }
    }
    notifyListeners();
    return message;
  }
  
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
  
  void toggleCigaretteMode(int index) {
    if (index < _cart.length && (_cart[index].product.isCigarette || _cart[index].product.category == 'cigarettes')) {
      _cart[index].isPackMode = !_cart[index].isPackMode;
      notifyListeners();
    }
  }
  
  Future<void> completeSale() async {
    try {
      // Create sale record
      final saleId = 'sale_${DateTime.now().millisecondsSinceEpoch}';
      final saleItems = <SaleItem>[];
      
      // Add cart items
      for (final cartItem in _cart) {
        if (cartItem.product.isCigarette || cartItem.product.category == 'cigarettes') {
          // Add cigarette item with mode suffix
          saleItems.add(SaleItem(
            productId: cartItem.product.id,
            productName: '${cartItem.product.name} (${cartItem.isPackMode ? 'Pack' : 'Piece'})',
            quantity: cartItem.quantity,
            price: cartItem.isPackMode ? (cartItem.product.packPrice ?? 0) : cartItem.product.price,
          ));
        } else {
          saleItems.add(SaleItem(
            productId: cartItem.product.id,
            productName: cartItem.product.name,
            quantity: cartItem.quantity,
            price: cartItem.product.getPriceForQuantity(1, isPackMode: cartItem.isPackMode),
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
        if (product.isCigarette || product.category == 'cigarettes') {
          if (cartItem.isPackMode) {
            product.sellPacks(cartItem.quantity);
          } else {
            product.sellPieces(cartItem.quantity);
          }
        } else {
          product.stock -= cartItem.quantity;
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
  
  CartItem({
    required this.product, 
    required this.quantity, 
    this.isPackMode = false,
  });
  
  double get totalPrice {
    if (product.isCigarette || product.category == 'cigarettes') {
      if (isPackMode) {
        return quantity * (product.packPrice ?? 0);
      } else {
        return quantity * product.price;
      }
    }
    return product.getPriceForQuantity(quantity, isPackMode: isPackMode);
  }
  
  String get displayQuantity {
    if (product.isCigarette || product.category == 'cigarettes') {
      return isPackMode ? '${quantity} pack${quantity > 1 ? 's' : ''}' : '${quantity} pc${quantity > 1 ? 's' : ''}';
    }
    return quantity.toString();
  }
  
  bool get isEmpty {
    return quantity == 0;
  }
}