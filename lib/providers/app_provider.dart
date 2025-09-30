import 'package:flutter/material.dart';
import '../models/product.dart';

class AppProvider extends ChangeNotifier {
  String _selectedPlatform = 'web';
  List<Product> _products = [];
  List<CartItem> _cart = [];
  Map<String, dynamic> _storeInfo = {};
  
  String get selectedPlatform => _selectedPlatform;
  List<Product> get products => _products;
  List<CartItem> get cart => _cart;
  Map<String, dynamic> get storeInfo => _storeInfo;
  
  double get cartTotal => _cart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.isLowStock).length;
  
  void setPlatform(String platform) {
    _selectedPlatform = platform;
    notifyListeners();
  }
  
  void loadSampleData() {
    _products = [
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
    ];
    notifyListeners();
  }
  
  Product? findProductByBarcode(String barcode) {
    return _products.where((p) => p.barcode == barcode).firstOrNull;
  }
  
  void addToCart(Product product) {
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      if (_cart[existingIndex].quantity < product.stock) {
        _cart[existingIndex].quantity++;
      }
    } else {
      _cart.add(CartItem(product: product, quantity: 1));
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
  
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
  
  void completeSale() {
    // Update stock
    for (final cartItem in _cart) {
      final product = _products.firstWhere((p) => p.id == cartItem.product.id);
      product.stock -= cartItem.quantity;
    }
    
    // Clear cart
    clearCart();
    notifyListeners();
  }
  
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }
  
  void updateProduct(Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }
  
  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    // Also remove from cart if present
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }
}

class CartItem {
  final Product product;
  int quantity;
  
  CartItem({required this.product, required this.quantity});
}