import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/sale.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'tindahan_ko.db';
  static const int _databaseVersion = 4;

  static const String _productsTable = 'products';
  static const String _salesTable = 'sales';
  static const String _saleItemsTable = 'sale_items';

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
        batchPrice REAL,
        isCigarette INTEGER DEFAULT 0,
        piecesPerPack INTEGER,
        packPrice REAL,
        loosePieces INTEGER DEFAULT 0,
        fullPacks INTEGER DEFAULT 0,
        autoOpenPack INTEGER DEFAULT 1
      )
    ''');
    
    await db.execute('''
      CREATE TABLE $_salesTable (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        total REAL NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE $_saleItemsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        saleId TEXT NOT NULL,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (saleId) REFERENCES $_salesTable (id)
      )
    ''');
  }
  
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_productsTable ADD COLUMN isBatchSelling INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE $_productsTable ADD COLUMN batchQuantity INTEGER');
      await db.execute('ALTER TABLE $_productsTable ADD COLUMN batchPrice REAL');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE $_salesTable (
          id TEXT PRIMARY KEY,
          date TEXT NOT NULL,
          total REAL NOT NULL
        )
      ''');
      
      await db.execute('''
        CREATE TABLE $_saleItemsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          saleId TEXT NOT NULL,
          productId TEXT NOT NULL,
          productName TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          price REAL NOT NULL,
          FOREIGN KEY (saleId) REFERENCES $_salesTable (id)
        )
      ''');
      
      await db.execute('ALTER TABLE $_productsTable ADD COLUMN isCigarette INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE $_productsTable ADD COLUMN piecesPerPack INTEGER');
      await db.execute('ALTER TABLE $_productsTable ADD COLUMN packPrice REAL');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE $_productsTable ADD COLUMN loosePieces INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE $_productsTable ADD COLUMN fullPacks INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE $_productsTable ADD COLUMN autoOpenPack INTEGER DEFAULT 1');
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
      'isCigarette': product.isCigarette ? 1 : 0,
      'piecesPerPack': product.piecesPerPack,
      'packPrice': product.packPrice,
      'loosePieces': product.loosePieces,
      'fullPacks': product.fullPacks,
      'autoOpenPack': product.autoOpenPack ? 1 : 0,
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
      isCigarette: (map['isCigarette'] ?? 0) == 1,
      piecesPerPack: map['piecesPerPack'] ?? 20,
      packPrice: map['packPrice'],
      loosePieces: map['loosePieces'] ?? 0,
      fullPacks: map['fullPacks'] ?? 0,
      autoOpenPack: (map['autoOpenPack'] ?? 1) == 1,
    );
  }

  // Sales operations
  static Future<void> insertSale(Sale sale) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(_salesTable, {
        'id': sale.id,
        'date': sale.date.toIso8601String(),
        'total': sale.total,
      });
      
      for (final item in sale.items) {
        await txn.insert(_saleItemsTable, {
          'saleId': sale.id,
          'productId': item.productId,
          'productName': item.productName,
          'quantity': item.quantity,
          'price': item.price,
        });
      }
    });
  }

  static Future<List<Sale>> getAllSales() async {
    final db = await database;
    final salesMaps = await db.query(_salesTable, orderBy: 'date DESC');
    
    List<Sale> sales = [];
    for (final saleMap in salesMaps) {
      final itemsMaps = await db.query(
        _saleItemsTable,
        where: 'saleId = ?',
        whereArgs: [saleMap['id']],
      );
      
      final items = itemsMaps.map((itemMap) => SaleItem(
        productId: itemMap['productId'] as String,
        productName: itemMap['productName'] as String,
        quantity: itemMap['quantity'] as int,
        price: itemMap['price'] as double,
      )).toList();
      
      sales.add(Sale(
        id: saleMap['id'] as String,
        date: DateTime.parse(saleMap['date'] as String),
        total: saleMap['total'] as double,
        items: items,
      ));
    }
    
    return sales;
  }

  static Future<List<Sale>> getSalesInDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final salesMaps = await db.query(
      _salesTable,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    
    List<Sale> sales = [];
    for (final saleMap in salesMaps) {
      final itemsMaps = await db.query(
        _saleItemsTable,
        where: 'saleId = ?',
        whereArgs: [saleMap['id']],
      );
      
      final items = itemsMaps.map((itemMap) => SaleItem(
        productId: itemMap['productId'] as String,
        productName: itemMap['productName'] as String,
        quantity: itemMap['quantity'] as int,
        price: itemMap['price'] as double,
      )).toList();
      
      sales.add(Sale(
        id: saleMap['id'] as String,
        date: DateTime.parse(saleMap['date'] as String),
        total: saleMap['total'] as double,
        items: items,
      ));
    }
    
    return sales;
  }
}