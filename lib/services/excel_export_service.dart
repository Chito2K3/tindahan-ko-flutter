import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import '../models/product.dart';

class ExcelExportService {
  static const MethodChannel _channel = MethodChannel('tindahan_ko/excel_export');

  static Future<String> exportProducts(List<Product> products) async {
    // Create Excel file
    final excel = Excel.createExcel();
    final sheet = excel['Products'];
    
    // Add headers
    final headers = ['ID', 'Name', 'Price', 'Stock', 'Category', 'Emoji', 'Reorder Level', 'Has Barcode', 'Barcode'];
    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(headers[i]);
    }
    
    // Add product data
    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      final row = i + 1;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(product.id);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(product.name);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = DoubleCellValue(product.price);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = IntCellValue(product.stock);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue(product.category);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = TextCellValue(product.emoji);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = IntCellValue(product.reorderLevel);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value = TextCellValue(product.hasBarcode ? 'YES' : 'NO');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value = TextCellValue(product.barcode ?? '');
    }
    
    final bytes = excel.encode()!;
    final now = DateTime.now();
    final fileName = 'TindahanKo_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.xlsx';
    
    if (kIsWeb) {
      return _exportWeb(bytes, fileName);
    } else if (Platform.isAndroid) {
      return _exportAndroid(bytes, fileName);
    } else {
      return _exportOther(bytes, fileName);
    }
  }

  static Future<String> _exportWeb(List<int> bytes, String fileName) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = fileName;
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
    return 'Downloads/$fileName';
  }

  static Future<String> _exportAndroid(List<int> bytes, String fileName) async {
    try {
      final result = await _channel.invokeMethod('saveToDownloads', {
        'fileName': fileName,
        'bytes': bytes,
      });
      return result as String;
    } catch (e) {
      // Fallback to traditional method
      return _exportFallback(bytes, fileName);
    }
  }

  static Future<String> _exportOther(List<int> bytes, String fileName) async {
    return _exportFallback(bytes, fileName);
  }

  static Future<String> _exportFallback(List<int> bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}