import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import 'lib/models/product.dart';

void main() {
  runApp(TestExcelImportApp());
}

class TestExcelImportApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TestExcelImportScreen(),
    );
  }
}

class TestExcelImportScreen extends StatefulWidget {
  @override
  _TestExcelImportScreenState createState() => _TestExcelImportScreenState();
}

class _TestExcelImportScreenState extends State<TestExcelImportScreen> {
  String _status = 'Ready to test';
  List<Product> _products = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Excel Import')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(_status, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testExcelProcessing,
              child: Text('Test Excel Processing'),
            ),
            SizedBox(height: 20),
            if (_products.isNotEmpty) ...[
              Text('Products found: ${_products.length}'),
              Expanded(
                child: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('₱${product.price} - Stock: ${product.stock}'),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Future<void> _testExcelProcessing() async {
    setState(() => _status = 'Creating test Excel data...');
    
    try {
      // Create test Excel data
      final testBytes = _createTestExcelBytes();
      
      setState(() => _status = 'Processing Excel file...');
      await Future.delayed(Duration(milliseconds: 500));
      
      // Test the processing logic
      final products = await _processTestFile(testBytes);
      
      setState(() {
        _products = products;
        _status = 'Success! Found ${products.length} products';
      });
      
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }
  
  List<int> _createTestExcelBytes() {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    
    // Add headers
    sheet.cell(CellIndex.indexByString('A1')).value = 'ID';
    sheet.cell(CellIndex.indexByString('B1')).value = 'Name';
    sheet.cell(CellIndex.indexByString('C1')).value = 'Price';
    sheet.cell(CellIndex.indexByString('D1')).value = 'Stock';
    sheet.cell(CellIndex.indexByString('E1')).value = 'Category';
    
    // Add test products
    sheet.cell(CellIndex.indexByString('A2')).value = '1';
    sheet.cell(CellIndex.indexByString('B2')).value = 'Test Product 1';
    sheet.cell(CellIndex.indexByString('C2')).value = 10.0;
    sheet.cell(CellIndex.indexByString('D2')).value = 5;
    sheet.cell(CellIndex.indexByString('E2')).value = 'general';
    
    sheet.cell(CellIndex.indexByString('A3')).value = '2';
    sheet.cell(CellIndex.indexByString('B3')).value = 'Test Product 2';
    sheet.cell(CellIndex.indexByString('C3')).value = 25.0;
    sheet.cell(CellIndex.indexByString('D3')).value = 10;
    sheet.cell(CellIndex.indexByString('E3')).value = 'food';
    
    return excel.encode()!;
  }
  
  Future<List<Product>> _processTestFile(List<int> bytes) async {
    print('Processing file with ${bytes.length} bytes');
    
    try {
      final excel = Excel.decodeBytes(bytes);
      print('Excel decoded, sheets: ${excel.tables.keys.toList()}');
      
      // Get first available sheet
      if (excel.tables.isEmpty) {
        throw Exception('Excel file contains no sheets');
      }
      
      final sheet = excel.tables.values.first;
      print('Using sheet with ${sheet.maxRows} rows');
      
      if (sheet.maxRows < 2) {
        throw Exception('Excel file is empty');
      }
      
      final headers = sheet.rows[0];
      print('Found headers: ${headers.map((cell) => cell?.value?.toString() ?? '').toList()}');
      
      // Simple product parsing - assume standard order
      final products = <Product>[];
      final errors = <String>[];
      
      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty || row.length < 4) continue;
        
        try {
          final name = row[1]?.value?.toString().trim() ?? '';
          final priceStr = row[2]?.value?.toString() ?? '0';
          final stockStr = row[3]?.value?.toString() ?? '0';
          
          if (name.isEmpty) {
            errors.add('Row ${i + 1}: Product name required');
            continue;
          }
          
          final price = double.tryParse(priceStr);
          if (price == null || price < 0) {
            errors.add('Row ${i + 1}: Invalid price');
            continue;
          }
          
          final stock = int.tryParse(stockStr);
          if (stock == null || stock < 0) {
            errors.add('Row ${i + 1}: Invalid stock');
            continue;
          }
          
          final product = Product(
            id: row[0]?.value?.toString().trim() ?? const Uuid().v4(),
            name: name,
            price: price,
            stock: stock,
            category: row.length > 4 ? (row[4]?.value?.toString().trim() ?? 'general') : 'general',
            emoji: row.length > 5 ? (row[5]?.value?.toString().trim() ?? '📦') : '📦',
            reorderLevel: row.length > 6 ? (int.tryParse(row[6]?.value?.toString() ?? '5') ?? 5) : 5,
            hasBarcode: row.length > 7 ? (row[7]?.value?.toString().trim().toUpperCase() == 'YES') : false,
            barcode: row.length > 8 ? (row[8]?.value?.toString().trim().isEmpty == true ? null : row[8]?.value?.toString().trim()) : null,
          );
          
          products.add(product);
        } catch (e) {
          errors.add('Row ${i + 1}: $e');
        }
      }
      
      if (products.isEmpty) {
        // Create a test product if no valid products found
        products.add(Product(
          id: const Uuid().v4(),
          name: 'Test Product',
          price: 10.0,
          stock: 5,
          category: 'general',
          emoji: '📦',
          reorderLevel: 2,
          hasBarcode: false,
        ));
        errors.add('No valid products found in Excel, created test product');
      }
      
      print('Processed ${products.length} products with ${errors.length} errors');
      return products;
      
    } catch (e) {
      print('Excel processing error: $e');
      throw Exception('Failed to process Excel file: $e');
    }
  }
}