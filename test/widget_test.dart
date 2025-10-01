// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:tindahan_ko_flutter/main.dart';
import 'package:tindahan_ko_flutter/providers/app_provider.dart';
import 'package:tindahan_ko_flutter/models/product.dart';

void main() {
  group('Tindahan Ko Tests', () {
    test('TindahanKoApp widget can be created', () {
      const app = TindahanKoApp();
      expect(app, isNotNull);
    });

    test('AppProvider initializes correctly', () {
      final provider = AppProvider();
      expect(provider.products, isEmpty);
      expect(provider.cart, isEmpty);
      expect(provider.cartTotal, equals(0.0));
    });

    test('Product model works correctly', () {
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
      expect(product.isLowStock, isFalse); // stock (5) > reorderLevel (2), so not low stock
      
      // Test JSON serialization
      final json = product.toJson();
      expect(json['name'], equals('Test Product'));
      
      // Test JSON deserialization
      final productFromJson = Product.fromJson(json);
      expect(productFromJson.name, equals('Test Product'));
      expect(productFromJson.price, equals(10.0));
    });
  });
}
