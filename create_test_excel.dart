import 'dart:io';
import 'package:excel/excel.dart';

void main() async {
  print('Creating test Excel file with correct format...');
  
  // Create Excel file with exact format expected by the app
  final excel = Excel.createExcel();
  final sheet = excel['Products'];
  
  // Add headers exactly as exported by the app
  final headers = ['ID', 'Name', 'Price', 'Stock', 'Category', 'Emoji', 'Reorder Level', 'Has Barcode', 'Barcode'];
  for (int i = 0; i < headers.length; i++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(headers[i]);
  }
  
  // Add test products
  final testProducts = [
    ['1', 'Coca Cola', '15.0', '50', 'drinks', '🥤', '10', 'YES', '123456789'],
    ['2', 'Lucky Me Beef', '12.0', '30', 'noodles', '🍜', '5', 'YES', '987654321'],
    ['3', 'Pandesal', '2.0', '20', 'bread', '🍞', '5', 'NO', ''],
  ];
  
  for (int i = 0; i < testProducts.length; i++) {
    final product = testProducts[i];
    final row = i + 1;
    
    for (int j = 0; j < product.length; j++) {
      final value = product[j];
      if (j == 2) { // Price column
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row)).value = DoubleCellValue(double.parse(value));
      } else if (j == 3 || j == 6) { // Stock and Reorder Level columns
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row)).value = IntCellValue(int.parse(value));
      } else {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row)).value = TextCellValue(value);
      }
    }
  }
  
  // Save the file
  final bytes = excel.encode()!;
  final file = File('test_products.xlsx');
  await file.writeAsBytes(bytes);
  
  print('✓ Created test_products.xlsx with ${testProducts.length} products');
  print('File saved to: ${file.absolute.path}');
  print('This file should work with the Excel import feature.');
}