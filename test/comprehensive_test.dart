import 'package:flutter_test/flutter_test.dart';
import 'package:tindahan_ko_flutter/models/product.dart';
import 'package:tindahan_ko_flutter/providers/app_provider.dart';

void main() {
  group('Comprehensive Tindahan Ko Tests', () {
    
    group('Product Model Tests', () {
      test('Regular product creation and properties', () {
        final product = Product(
          id: 'test1',
          name: 'Test Product',
          price: 10.0,
          stock: 5,
          category: 'test',
          emoji: '📦',
          reorderLevel: 2,
          hasBarcode: true,
          barcode: '123456',
        );
        
        expect(product.name, equals('Test Product'));
        expect(product.price, equals(10.0));
        expect(product.stock, equals(5));
        expect(product.isLowStock, isFalse);
        expect(product.isOutOfStock, isFalse);
        expect(product.totalPieces, equals(5));
      });

      test('Cigarette product creation and properties', () {
        final cigarette = Product(
          id: 'cig1',
          name: 'Winston',
          price: 10.0,
          stock: 400,
          category: 'cigarettes',
          emoji: '🚬',
          reorderLevel: 2,
          hasBarcode: true,
          barcode: '123456789',
          isCigarette: true,
          piecesPerPack: 20,
          packPrice: 190.0,
          packStock: 20,
        );
        
        expect(cigarette.isCigarette, isTrue);
        expect(cigarette.packPrice, equals(190.0));
        expect(cigarette.packStock, equals(20));
        expect(cigarette.piecesPerPack, equals(20));
        expect(cigarette.totalPieces, equals(400)); // 20 packs * 20 pieces
      });

      test('Cigarette stick selling logic', () {
        final cigarette = Product(
          id: 'cig1',
          name: 'Winston',
          price: 10.0,
          stock: 400,
          category: 'cigarettes',
          emoji: '🚬',
          reorderLevel: 2,
          hasBarcode: true,
          isCigarette: true,
          piecesPerPack: 20,
          packPrice: 190.0,
          packStock: 2,
        );
        
        // Set initial stick buffer
        cigarette.setStickBuffer(5);
        
        // Test selling 3 sticks from buffer
        expect(cigarette.canSellSticks(3), isTrue);
        cigarette.sellSticks(3);
        expect(cigarette.stickBuffer, equals(2));
        expect(cigarette.packStock, equals(2)); // Should remain unchanged
        
        // Test selling more sticks than buffer (should open pack)
        cigarette.sellSticks(10);
        expect(cigarette.stickBuffer, equals(12)); // 2 remaining + 20 from opened pack - 10 sold
        expect(cigarette.packStock, equals(1)); // One pack should be opened
      });

      test('Cigarette pack selling logic', () {
        final cigarette = Product(
          id: 'cig1',
          name: 'Winston',
          price: 10.0,
          stock: 400,
          category: 'cigarettes',
          emoji: '🚬',
          reorderLevel: 2,
          hasBarcode: true,
          isCigarette: true,
          piecesPerPack: 20,
          packPrice: 190.0,
          packStock: 5,
        );
        
        expect(cigarette.canSellPacks(3), isTrue);
        cigarette.sellPacks(3);
        expect(cigarette.packStock, equals(2));
      });

      test('Batch selling product logic', () {
        final batchProduct = Product(
          id: 'batch1',
          name: 'Mentos',
          price: 2.0,
          stock: 100,
          category: 'candies',
          emoji: '🍬',
          reorderLevel: 20,
          hasBarcode: false,
          isBatchSelling: true,
          batchQuantity: 3,
          batchPrice: 5.0,
        );
        
        expect(batchProduct.isBatchSelling, isTrue);
        expect(batchProduct.getPriceForQuantity(3), equals(5.0));
        expect(batchProduct.getPriceForQuantity(4), equals(7.0)); // 5.0 + 2.0
        expect(batchProduct.getPriceForQuantity(6), equals(10.0)); // 2 batches
      });
    });

    group('AppProvider Tests', () {
      test('AppProvider initialization', () {
        final provider = AppProvider();
        expect(provider.products, isEmpty);
        expect(provider.cart, isEmpty);
        expect(provider.cartTotal, equals(0.0));
        expect(provider.totalProducts, equals(0));
        expect(provider.lowStockCount, equals(0));
        expect(provider.outOfStockCount, equals(0));
      });

      test('Add regular product to cart', () {
        final provider = AppProvider();
        final product = Product(
          id: 'test1',
          name: 'Test Product',
          price: 10.0,
          stock: 5,
          category: 'test',
          emoji: '📦',
          reorderLevel: 2,
          hasBarcode: false,
        );
        
        provider.addToCart(product);
        expect(provider.cart.length, equals(1));
        expect(provider.cart.first.quantity, equals(1));
        expect(provider.cartTotal, equals(10.0));
        
        // Add same product again
        provider.addToCart(product);
        expect(provider.cart.length, equals(1));
        expect(provider.cart.first.quantity, equals(2));
        expect(provider.cartTotal, equals(20.0));
      });

      test('Add cigarette to cart (stick mode)', () {
        final provider = AppProvider();
        final cigarette = Product(
          id: 'cig1',
          name: 'Winston',
          price: 10.0,
          stock: 400,
          category: 'cigarettes',
          emoji: '🚬',
          reorderLevel: 2,
          hasBarcode: true,
          isCigarette: true,
          piecesPerPack: 20,
          packPrice: 190.0,
          packStock: 20,
        );
        cigarette.setStickBuffer(40);
        
        provider.addToCart(cigarette, isPackMode: false);
        expect(provider.cart.length, equals(1));
        expect(provider.cart.first.quantity, equals(1));
        expect(provider.cart.first.isPackMode, isFalse);
        expect(provider.cartTotal, equals(10.0));
      });

      test('Add cigarette to cart (pack mode)', () {
        final provider = AppProvider();
        final cigarette = Product(
          id: 'cig1',
          name: 'Winston',
          price: 10.0,
          stock: 400,
          category: 'cigarettes',
          emoji: '🚬',
          reorderLevel: 2,
          hasBarcode: true,
          isCigarette: true,
          piecesPerPack: 20,
          packPrice: 190.0,
          packStock: 20,
        );
        
        provider.addToCart(cigarette, isPackMode: true);
        expect(provider.cart.length, equals(1));
        expect(provider.cart.first.quantity, equals(1));
        expect(provider.cart.first.isPackMode, isTrue);
        expect(provider.cartTotal, equals(190.0));
      });

      test('Add batch selling product to cart', () {
        final provider = AppProvider();
        final batchProduct = Product(
          id: 'batch1',
          name: 'Mentos',
          price: 2.0,
          stock: 100,
          category: 'candies',
          emoji: '🍬',
          reorderLevel: 20,
          hasBarcode: false,
          isBatchSelling: true,
          batchQuantity: 3,
          batchPrice: 5.0,
        );
        
        provider.addToCart(batchProduct);
        expect(provider.cart.length, equals(1));
        expect(provider.cart.first.quantity, equals(3)); // Should add batch quantity
        expect(provider.cartTotal, equals(5.0)); // Should use batch price
      });

      test('Cart quantity updates', () {
        final provider = AppProvider();
        final product = Product(
          id: 'test1',
          name: 'Test Product',
          price: 10.0,
          stock: 10,
          category: 'test',
          emoji: '📦',
          reorderLevel: 2,
          hasBarcode: false,
        );
        
        provider.addToCart(product);
        expect(provider.cart.first.quantity, equals(1));
        
        // Test increment
        final message = provider.updateCartQuantityByIncrement(0, 1, 1);
        expect(message, isNull);
        expect(provider.cart.first.quantity, equals(2));
        
        // Test decrement
        provider.updateCartQuantityByIncrement(0, -1, 1);
        expect(provider.cart.first.quantity, equals(1));
        
        // Test remove (quantity becomes 0)
        provider.updateCartQuantityByIncrement(0, -1, 1);
        expect(provider.cart.length, equals(0));
      });

      test('Clear cart functionality', () {
        final provider = AppProvider();
        final product = Product(
          id: 'test1',
          name: 'Test Product',
          price: 10.0,
          stock: 5,
          category: 'test',
          emoji: '📦',
          reorderLevel: 2,
          hasBarcode: false,
        );
        
        provider.addToCart(product);
        expect(provider.cart.length, equals(1));
        
        provider.clearCart();
        expect(provider.cart.length, equals(0));
        expect(provider.cartTotal, equals(0.0));
      });
    });

    group('CartItem Tests', () {
      test('Regular cart item properties', () {
        final product = Product(
          id: 'test1',
          name: 'Test Product',
          price: 10.0,
          stock: 5,
          category: 'test',
          emoji: '📦',
          reorderLevel: 2,
          hasBarcode: false,
        );
        
        final cartItem = CartItem(product: product, quantity: 3);
        expect(cartItem.totalPrice, equals(30.0));
        expect(cartItem.displayQuantity, equals('3'));
        expect(cartItem.isEmpty, isFalse);
      });

      test('Cigarette cart item properties (stick mode)', () {
        final cigarette = Product(
          id: 'cig1',
          name: 'Winston',
          price: 10.0,
          stock: 400,
          category: 'cigarettes',
          emoji: '🚬',
          reorderLevel: 2,
          hasBarcode: true,
          isCigarette: true,
          piecesPerPack: 20,
          packPrice: 190.0,
          packStock: 20,
        );
        
        final cartItem = CartItem(product: cigarette, quantity: 5, isPackMode: false);
        expect(cartItem.totalPrice, equals(50.0)); // 5 * 10.0
        expect(cartItem.displayQuantity, equals('5 sticks'));
        expect(cartItem.isPackMode, isFalse);
      });

      test('Cigarette cart item properties (pack mode)', () {
        final cigarette = Product(
          id: 'cig1',
          name: 'Winston',
          price: 10.0,
          stock: 400,
          category: 'cigarettes',
          emoji: '🚬',
          reorderLevel: 2,
          hasBarcode: true,
          isCigarette: true,
          piecesPerPack: 20,
          packPrice: 190.0,
          packStock: 20,
        );
        
        final cartItem = CartItem(product: cigarette, quantity: 2, isPackMode: true);
        expect(cartItem.totalPrice, equals(380.0)); // 2 * 190.0
        expect(cartItem.displayQuantity, equals('2 packs'));
        expect(cartItem.isPackMode, isTrue);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('Adding product with insufficient stock', () {
        final provider = AppProvider();
        final product = Product(
          id: 'test1',
          name: 'Test Product',
          price: 10.0,
          stock: 2,
          category: 'test',
          emoji: '📦',
          reorderLevel: 1,
          hasBarcode: false,
        );
        
        // Add to cart twice (should work)
        provider.addToCart(product);
        provider.addToCart(product);
        expect(provider.cart.first.quantity, equals(2));
        
        // Try to add more than available stock (should not increase)
        provider.addToCart(product);
        expect(provider.cart.first.quantity, equals(2)); // Should remain 2
      });

      test('Cigarette stick limit per cart item', () {
        final provider = AppProvider();
        final cigarette = Product(
          id: 'cig1',
          name: 'Winston',
          price: 10.0,
          stock: 400,
          category: 'cigarettes',
          emoji: '🚬',
          reorderLevel: 2,
          hasBarcode: true,
          isCigarette: true,
          piecesPerPack: 20,
          packPrice: 190.0,
          packStock: 20,
        );
        cigarette.setStickBuffer(100);
        
        provider.addToCart(cigarette, isPackMode: false);
        
        // Try to add 19 more sticks (should work - total 20)
        for (int i = 0; i < 18; i++) {
          provider.updateCartQuantityByIncrement(0, 1, 1);
        }
        expect(provider.cart.first.quantity, equals(19));
        
        // Try to add one more (should show limit message)
        final message = provider.updateCartQuantityByIncrement(0, 1, 1);
        expect(message, contains('Maximum 19 sticks per cart item'));
        expect(provider.cart.first.quantity, equals(19)); // Should remain 19
      });

      test('Out of stock product behavior', () {
        final product = Product(
          id: 'test1',
          name: 'Out of Stock Product',
          price: 10.0,
          stock: 0,
          category: 'test',
          emoji: '📦',
          reorderLevel: 2,
          hasBarcode: false,
        );
        
        expect(product.isOutOfStock, isTrue);
        expect(product.stockDisplay, equals('Out of Stock'));
      });

      test('Cigarette out of stock behavior', () {
        final cigarette = Product(
          id: 'cig1',
          name: 'Winston',
          price: 10.0,
          stock: 0,
          category: 'cigarettes',
          emoji: '🚬',
          reorderLevel: 2,
          hasBarcode: true,
          isCigarette: true,
          piecesPerPack: 20,
          packPrice: 190.0,
          packStock: 0,
        );
        cigarette.setStickBuffer(0);
        
        expect(cigarette.isOutOfStock, isTrue);
        expect(cigarette.stockDisplay, equals('Out of Stock'));
        expect(cigarette.canSellSticks(1), isFalse);
        expect(cigarette.canSellPacks(1), isFalse);
      });
    });
  });
}