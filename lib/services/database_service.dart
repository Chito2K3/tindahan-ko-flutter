import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'tindahan_ko.db';
  static const int _databaseVersion = 2;

  static const String _productsTable = 'products';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_productsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        category TEXT NOT NULL,
        emoji TEXT NOT NULL,
        reorderLevel INTEGER NOT NULL,
        hasBarcode INTEGER NOT NULL,
        barcode TEXT,
        isBatchSelling INTEGER DEFAULT 0,
        batchQuantity INTEGER,
        batchPrice REAL
      )
    ''');
  }
  
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_productsTable ADD COLUMN isBatchSelling INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE $_productsTable ADD COLUMN batchQuantity INTEGER');
      await db.execute('ALTER TABLE $_productsTable ADD COLUMN batchPrice REAL');
    }
  }

  // Product operations
  static Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert(
      _productsTable,
      _productToMap(product),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_productsTable);
    return List.generate(maps.length, (i) => _productFromMap(maps[i]));
  }

  static Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      _productsTable,
      _productToMap(product),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  static Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete(
      _productsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _productsTable,
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    
    if (maps.isNotEmpty) {
      return _productFromMap(maps.first);
    }
    return null;
  }

  // Helper methods
  static Map<String, dynamic> _productToMap(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'stock': product.stock,
      'category': product.category,
      'emoji': product.emoji,
      'reorderLevel': product.reorderLevel,
      'hasBarcode': product.hasBarcode ? 1 : 0,
      'barcode': product.barcode,
      'isBatchSelling': product.isBatchSelling ? 1 : 0,
      'batchQuantity': product.batchQuantity,
      'batchPrice': product.batchPrice,
    };
  }

  static Product _productFromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      stock: map['stock'],
      category: map['category'],
      emoji: map['emoji'],
      reorderLevel: map['reorderLevel'],
      hasBarcode: map['hasBarcode'] == 1,
      barcode: map['barcode'],
      isBatchSelling: map['isBatchSelling'] == 1,
      batchQuantity: map['batchQuantity'],
      batchPrice: map['batchPrice'],
    );
  }
}