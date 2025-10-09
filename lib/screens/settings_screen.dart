import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../services/database_service.dart';
import '../models/product.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart' show PlatformFile;
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onStoreInfoUpdated;
  
  const SettingsScreen({super.key, this.onStoreInfoUpdated});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, ThemeProvider>(
      builder: (context, provider, themeProvider, child) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView(
                  children: [
                    _SettingsCard(
                      title: 'Store Information',
                      subtitle: 'Manage store details',
                      icon: Icons.store,
                      onTap: () => _showStoreInfo(context, onStoreInfoUpdated),
                    ),
                    
                    _SettingsCard(
                      title: 'Backup & Restore',
                      subtitle: 'Export/Import data',
                      icon: Icons.backup,
                      onTap: () => _showBackupOptions(context),
                    ),
                    
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return _SettingsCard(
                          title: 'Theme',
                          subtitle: themeProvider.isDarkMode ? 'Dark mode enabled' : 'Light mode enabled',
                          icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          onTap: () => themeProvider.toggleTheme(),
                        );
                      },
                    ),
                    
                    _SettingsCard(
                      title: 'About',
                      subtitle: 'App version and info',
                      icon: Icons.info,
                      onTap: () => _showAbout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStoreInfo(BuildContext context, VoidCallback? onUpdated) {
    showDialog(
      context: context,
      builder: (context) => _StoreInfoDialog(onUpdated: onUpdated),
    );
  }

  void _showBackupOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _BackupDialog(),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AboutDialog(),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _StoreInfoDialog extends StatefulWidget {
  final VoidCallback? onUpdated;
  
  const _StoreInfoDialog({this.onUpdated});

  @override
  State<_StoreInfoDialog> createState() => _StoreInfoDialogState();
}

class _StoreInfoDialogState extends State<_StoreInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _ownerNameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _loadStoreInfo();
  }

  Future<void> _loadStoreInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storeNameController.text = prefs.getString('store_name') ?? '';
      _ownerNameController.text = prefs.getString('owner_name') ?? '';
      _addressController.text = prefs.getString('store_address') ?? '';
      _phoneController.text = prefs.getString('store_phone') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text('Store Information', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      content: SizedBox(
        width: 300,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _storeNameController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Store Name',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                  ),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              TextFormField(
                controller: _ownerNameController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Owner Name',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                  ),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              TextFormField(
                controller: _addressController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                  ),
                ),
              ),
              TextFormField(
                controller: _phoneController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        ),
        TextButton(
          onPressed: _saveStoreInfo,
          child: Text('Save', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
      ],
    );
  }

  Future<void> _saveStoreInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('store_name', _storeNameController.text);
    await prefs.setString('owner_name', _ownerNameController.text);
    await prefs.setString('store_address', _addressController.text);
    await prefs.setString('store_phone', _phoneController.text);

    Navigator.pop(context);
    widget.onUpdated?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Store information saved'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

class _BackupDialog extends StatelessWidget {
  const _BackupDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text('Backup & Restore', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.upload, color: Theme.of(context).colorScheme.primary),
            title: Text('Export to Excel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text('Download products as .xlsx file', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
            title: Text('Import from Excel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text('Upload .xlsx file to restore products', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            onTap: () => _importData(context),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      // Request storage permission for Android
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission required to export files'), backgroundColor: Colors.red),
          );
          return;
        }
      }
      
      final products = await DatabaseService.getAllProducts();
      
      // Create Excel file
      final excel = Excel.createExcel();
      final sheet = excel['Products'];
      
      // Add headers
      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('ID');
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Name');
      sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Price');
      sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Stock');
      sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Category');
      sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('Emoji');
      sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue('Reorder Level');
      sheet.cell(CellIndex.indexByString('H1')).value = TextCellValue('Has Barcode');
      sheet.cell(CellIndex.indexByString('I1')).value = TextCellValue('Barcode');
      
      // Add product data
      for (int i = 0; i < products.length; i++) {
        final product = products[i];
        final row = i + 2;
        
        sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(product.id);
        sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(product.name);
        sheet.cell(CellIndex.indexByString('C$row')).value = DoubleCellValue(product.price);
        sheet.cell(CellIndex.indexByString('D$row')).value = IntCellValue(product.stock);
        sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(product.category);
        sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(product.emoji);
        sheet.cell(CellIndex.indexByString('G$row')).value = IntCellValue(product.reorderLevel);
        sheet.cell(CellIndex.indexByString('H$row')).value = TextCellValue(product.hasBarcode ? 'YES' : 'NO');
        sheet.cell(CellIndex.indexByString('I$row')).value = TextCellValue(product.barcode ?? '');
      }
      
      // Save file
      final bytes = excel.encode();
      final now = DateTime.now();
      final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final fileName = 'TindahanKo$dateStr.xlsx';
      
      if (kIsWeb) {
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
      } else {
        // For Android - save to Downloads folder
        String filePath;
        try {
          // Try Downloads folder first (Android 10+)
          final downloadsPath = '/storage/emulated/0/Download';
          final downloadsDir = Directory(downloadsPath);
          if (await downloadsDir.exists()) {
            filePath = path.join(downloadsPath, fileName);
          } else {
            // Fallback for older Android versions
            final directory = await getExternalStorageDirectory();
            filePath = path.join(directory!.path, fileName);
          }
        } catch (e) {
          // Final fallback
          final directory = await getApplicationDocumentsDirectory();
          filePath = path.join(directory.path, fileName);
        }
        
        final file = File(filePath);
        await file.writeAsBytes(bytes!);
      }
      
      Navigator.pop(context);
      
      final filePath = kIsWeb ? 'Downloads' : '/storage/emulated/0/Download';
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Export Successful', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              Text('Products exported to Excel successfully!', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text('${products.length} products exported', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
              const SizedBox(height: 8),
              Text('File: $fileName', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
              const SizedBox(height: 8),
              Text('Location: $filePath', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 11)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File saved to Downloads: $fileName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    Navigator.pop(context); // Close backup dialog first
    
    try {
      // Show file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );
      
      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }
      
      final file = result.files.first;
      if (file.bytes == null) {
        _showError(context, 'File Error', 'Could not read the selected file. Please try again.');
        return;
      }
      
      // Show progress dialog
      _showProgressDialog(context, 'Reading Excel file...');
      
      await Future.delayed(const Duration(milliseconds: 500)); // Allow UI to update
      
      try {
        // Validate file format
        _updateProgress(context, 'Validating file format...');
        final excel = Excel.decodeBytes(file.bytes!);
        final sheet = excel.tables['Products'];
        
        if (sheet == null) {
          _closeProgress(context);
          _showError(context, 'Invalid File Format', 
            'This file is not a valid Tindahan Ko Excel file.\n\n'
            'Expected: Excel file with "Products" sheet\n'
            'Please export from Tindahan Ko first to get the correct format.');
          return;
        }
        
        if (sheet.maxRows < 2) {
          _closeProgress(context);
          _showError(context, 'Empty File', 'The Excel file contains no product data.\n\nPlease check your file and try again.');
          return;
        }
        
        // Validate headers
        _updateProgress(context, 'Checking file structure...');
        final headers = sheet.rows[0];
        final expectedHeaders = ['ID', 'Name', 'Price', 'Stock', 'Category', 'Emoji', 'Reorder Level', 'Has Barcode', 'Barcode'];
        
        final List<String> missingHeaders = [];
        for (int i = 0; i < expectedHeaders.length && i < headers.length; i++) {
          final headerValue = headers[i]?.value?.toString().trim() ?? '';
          if (headerValue != expectedHeaders[i]) {
            missingHeaders.add('Column ${String.fromCharCode(65 + i)}: Expected "${expectedHeaders[i]}", found "$headerValue"');
          }
        }
        
        if (missingHeaders.isNotEmpty) {
          _closeProgress(context);
          _showError(context, 'Invalid File Structure', 
            'The Excel file structure doesn\'t match Tindahan Ko format:\n\n'
            '${missingHeaders.join('\n')}\n\n'
            'Please use a file exported from Tindahan Ko.');
          return;
        }
        
        // Parse and validate products
        _updateProgress(context, 'Processing products...');
        final products = <Product>[];
        final errors = <String>[];
        
        for (int i = 1; i < sheet.maxRows; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty || (row.length > 1 && row[1]?.value?.toString().trim().isEmpty == true)) {
            continue; // Skip empty rows
          }
          
          try {
            final name = row[1]?.value?.toString().trim() ?? '';
            final priceStr = row[2]?.value?.toString() ?? '0';
            final stockStr = row[3]?.value?.toString() ?? '0';
            
            if (name.isEmpty) {
              errors.add('Row ${i + 1}: Product name is required');
              continue;
            }
            
            final price = double.tryParse(priceStr);
            if (price == null || price < 0) {
              errors.add('Row ${i + 1}: Invalid price "$priceStr"');
              continue;
            }
            
            final stock = int.tryParse(stockStr);
            if (stock == null || stock < 0) {
              errors.add('Row ${i + 1}: Invalid stock "$stockStr"');
              continue;
            }
            
            final product = Product(
              id: row[0]?.value?.toString().trim() ?? const Uuid().v4(),
              name: name,
              price: price,
              stock: stock,
              category: row[4]?.value?.toString().trim() ?? 'general',
              emoji: row[5]?.value?.toString().trim() ?? '📦',
              reorderLevel: int.tryParse(row[6]?.value?.toString() ?? '5') ?? 5,
              hasBarcode: row[7]?.value?.toString().trim().toUpperCase() == 'YES',
              barcode: row[8]?.value?.toString().trim().isEmpty == true ? null : row[8]?.value?.toString().trim(),
            );
            
            products.add(product);
          } catch (e) {
            errors.add('Row ${i + 1}: $e');
          }
        }
        
        _closeProgress(context);
        
        // Show validation results
        if (products.isEmpty) {
          String errorMsg = 'No valid products found in the Excel file.';
          if (errors.isNotEmpty) {
            errorMsg += '\n\nErrors found:\n${errors.take(5).join('\n')}';
            if (errors.length > 5) {
              errorMsg += '\n... and ${errors.length - 5} more errors';
            }
          }
          _showError(context, 'No Valid Data', errorMsg);
          return;
        }
        
        // Show confirmation with details
        final confirmed = await _showConfirmDialog(context, products.length, errors.length);
        if (!confirmed) return;
        
        // Import products with progress
        _showProgressDialog(context, 'Importing products...');
        
        // Clear existing products
        _updateProgress(context, 'Clearing existing data...');
        final existingProducts = await DatabaseService.getAllProducts();
        for (int i = 0; i < existingProducts.length; i++) {
          await DatabaseService.deleteProduct(existingProducts[i].id);
          if (i % 10 == 0) {
            _updateProgress(context, 'Clearing existing data... ${i + 1}/${existingProducts.length}');
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }
        
        // Insert new products
        for (int i = 0; i < products.length; i++) {
          await DatabaseService.insertProduct(products[i]);
          if (i % 5 == 0) {
            _updateProgress(context, 'Importing products... ${i + 1}/${products.length}');
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }
        
        // Refresh app data
        _updateProgress(context, 'Refreshing data...');
        if (context.mounted) {
          await Provider.of<AppProvider>(context, listen: false).loadProducts();
        }
        
        _closeProgress(context);
        _showSuccess(context, products.length, errors.length);
        
      } catch (e) {
        _closeProgress(context);
        _showError(context, 'Import Failed', 
          'An error occurred while processing the Excel file:\n\n$e\n\n'
          'Please check your file format and try again.');
      }
      
    } catch (e) {
      _showError(context, 'File Selection Error', 
        'Could not open the file picker:\n\n$e\n\n'
        'Please check your device permissions and try again.');
    }
  }
  
  void _showProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _updateProgress(BuildContext context, String message) {
    // Close current dialog and show new one with updated message
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _showProgressDialog(context, message);
  }
  
  void _closeProgress(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
  
  void _showError(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Future<bool> _showConfirmDialog(BuildContext context, int productCount, int errorCount) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Icon(Icons.upload_file, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text('Confirm Import', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            Text(
              'Ready to import $productCount products',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (errorCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$errorCount rows had errors and will be skipped',
                style: const TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will replace ALL existing products',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Import Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  
  void _showSuccess(BuildContext context, int productCount, int errorCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Import Successful', style: TextStyle(color: Colors.green)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_done, color: Colors.green, size: 64),
            const SizedBox(height: 20),
            Text(
              '$productCount products imported successfully!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory, color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Database updated successfully',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (errorCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$errorCount rows were skipped due to errors',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    // Also show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $productCount products imported successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Text('About', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📱', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        'Tindahan Ko',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para sa mga Reyna ng Tahanan 👑',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Version 1.4.1',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A complete Point of Sale and Inventory Management System designed specifically for Filipino sari-sari stores.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code, color: Theme.of(context).colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Developer',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Chito Saba',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'chitosaba@gmail.com',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Key Features:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text('📱 Native barcode scanning', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13)),
            Text('💰 Point of Sale system', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13)),
            Text('📦 Inventory management', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13)),
            Text('🚬 Dual-unit cigarette system', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13)),
            Text('📊 Real sales tracking & reports', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13)),
            Text('💾 Data backup & restore', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13)),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '© 2024 Chito Saba. All rights reserved.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Close',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}