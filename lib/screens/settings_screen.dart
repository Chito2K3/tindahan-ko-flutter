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
    try {
      Navigator.pop(context);
      
      // Request storage permission for Android
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission required'), backgroundColor: Colors.red),
          );
          return;
        }
      }
      
      // Show import method selection
      final method = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Import Method', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.folder_open, color: Colors.blue),
                title: Text('Browse Files', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                subtitle: Text('Use file picker', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                onTap: () => Navigator.pop(context, 'picker'),
              ),
              ListTile(
                leading: Icon(Icons.download, color: Colors.green),
                title: Text('From Downloads', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                subtitle: Text('Auto-find Excel files', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                onTap: () => Navigator.pop(context, 'downloads'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
      
      if (method == null) return;
      
      FilePickerResult? result;
      
      if (method == 'downloads') {
        // Look for Excel files in Downloads folder
        final downloadsPath = '/storage/emulated/0/Download';
        final downloadsDir = Directory(downloadsPath);
        
        if (await downloadsDir.exists()) {
          final files = await downloadsDir.list().where((file) => 
            file.path.toLowerCase().endsWith('.xlsx')).toList();
          
          if (files.isEmpty) {
            throw Exception('No Excel files found in Downloads folder');
          }
          
          String? selectedFile;
          if (files.length == 1) {
            selectedFile = files.first.path;
          } else {
            selectedFile = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Select Excel File'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: files.map((file) => ListTile(
                    title: Text(path.basename(file.path)),
                    onTap: () => Navigator.pop(context, file.path),
                  )).toList(),
                ),
              ),
            );
          }
          
          if (selectedFile != null) {
            final file = File(selectedFile);
            final bytes = await file.readAsBytes();
            result = FilePickerResult([PlatformFile(
              name: path.basename(selectedFile),
              size: bytes.length,
              bytes: bytes,
              path: selectedFile,
            )]);
          }
        } else {
          throw Exception('Downloads folder not accessible');
        }
      } else {
        // Try file picker
        try {
          result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            withData: true,
            allowMultiple: false,
          );
        } catch (e) {
          throw Exception('File picker not supported. Please use "From Downloads" method.');
        }
      }
      
      if (result != null && result.files.single.bytes != null) {
        final fileName = result.files.single.name;
        final bytes = result.files.single.bytes!;
        
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Checking file...', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        );
        
        try {
          // Validate file extension
          if (!fileName.toLowerCase().endsWith('.xlsx')) {
            Navigator.pop(context); // Close loading
            throw Exception('Invalid file type. Only Excel files (.xlsx) are supported.');
          }
          
          // Validate file size (max 10MB)
          if (bytes.length > 10 * 1024 * 1024) {
            Navigator.pop(context); // Close loading
            throw Exception('File too large. Maximum size is 10MB.');
          }
          
          // Try to decode Excel file
          Excel excel;
          try {
            excel = Excel.decodeBytes(bytes);
          } catch (e) {
            Navigator.pop(context); // Close loading
            throw Exception('Invalid Excel file. File may be corrupted or not a valid Excel format.');
          }
        
          // Validate sheet structure
          final sheet = excel.tables['Products'];
          if (sheet == null) {
            Navigator.pop(context); // Close loading
            throw Exception('Invalid file structure: No "Products" sheet found.\n\nPlease use a valid Tindahan Ko export file or create a sheet named "Products".');
          }
          
          // Validate minimum rows
          if (sheet.maxRows < 2) {
            Navigator.pop(context); // Close loading
            throw Exception('Invalid file: File is empty or contains no product data.\n\nThe file must have at least a header row and one product row.');
          }
          
          // Validate headers
          final headers = sheet.rows[0];
          final expectedHeaders = ['ID', 'Name', 'Price', 'Stock', 'Category', 'Emoji', 'Reorder Level', 'Has Barcode', 'Barcode'];
          
          if (headers.length < expectedHeaders.length) {
            Navigator.pop(context); // Close loading
            throw Exception('Invalid file format: Missing columns.\n\nExpected ${expectedHeaders.length} columns, found ${headers.length}.\n\nRequired columns: ${expectedHeaders.join(", ")}');
          }
          
          // Check each header
          for (int i = 0; i < expectedHeaders.length; i++) {
            final headerValue = headers[i]?.value?.toString().trim() ?? '';
            if (headerValue != expectedHeaders[i]) {
              Navigator.pop(context); // Close loading
              throw Exception('Invalid column header in column ${String.fromCharCode(65 + i)}:\n\nExpected: "${expectedHeaders[i]}"\nFound: "$headerValue"\n\nPlease check your Excel file headers match exactly.');
            }
          }
        
          // Validate and parse products
          final products = <Product>[];
          final errors = <String>[];
          
          // Skip header row, start from row 1 (0-indexed)
          for (int i = 1; i < sheet.maxRows; i++) {
            final row = sheet.rows[i];
            if (row.isEmpty || row[1]?.value == null) continue;
            
            try {
              final name = row[1]?.value?.toString().trim() ?? '';
              if (name.isEmpty) {
                errors.add('Row ${i + 1}: Product name is required');
                continue;
              }
              
              final priceStr = row[2]?.value?.toString() ?? '0';
              final price = double.tryParse(priceStr);
              if (price == null || price < 0) {
                errors.add('Row ${i + 1}: Invalid price "$priceStr". Must be a valid number ≥ 0');
                continue;
              }
              
              final stockStr = row[3]?.value?.toString() ?? '0';
              final stock = int.tryParse(stockStr);
              if (stock == null || stock < 0) {
                errors.add('Row ${i + 1}: Invalid stock "$stockStr". Must be a valid number ≥ 0');
                continue;
              }
              
              final reorderStr = row[6]?.value?.toString() ?? '5';
              final reorderLevel = int.tryParse(reorderStr);
              if (reorderLevel == null || reorderLevel < 0) {
                errors.add('Row ${i + 1}: Invalid reorder level "$reorderStr". Must be a valid number ≥ 0');
                continue;
              }
              
              final hasBarcodeStr = row[7]?.value?.toString().trim().toUpperCase() ?? 'NO';
              if (!['YES', 'NO'].contains(hasBarcodeStr)) {
                errors.add('Row ${i + 1}: Invalid barcode flag "$hasBarcodeStr". Must be "YES" or "NO"');
                continue;
              }
              
              final id = row[0]?.value?.toString().trim();
              final category = row[4]?.value?.toString().trim();
              final emoji = row[5]?.value?.toString().trim();
              final barcode = row[8]?.value?.toString().trim();
              
              products.add(Product(
                id: id?.isEmpty == true ? const Uuid().v4() : id!,
                name: name,
                price: price,
                stock: stock,
                category: category?.isEmpty == true ? 'General' : category!,
                emoji: emoji?.isEmpty == true ? '📦' : emoji!,
                reorderLevel: reorderLevel,
                hasBarcode: hasBarcodeStr == 'YES',
                barcode: barcode?.isEmpty == true ? null : barcode,
              ));
            } catch (e) {
              errors.add('Row ${i + 1}: Error processing data - $e');
            }
          }
          
          Navigator.pop(context); // Close loading
          
          // Check for validation errors
          if (errors.isNotEmpty) {
            final errorMsg = errors.take(5).join('\n');
            final moreErrors = errors.length > 5 ? '\n\n...and ${errors.length - 5} more errors' : '';
            throw Exception('File validation failed:\n\n$errorMsg$moreErrors\n\nPlease fix these issues and try again.');
          }
        
          if (products.isEmpty) {
            throw Exception('No valid products found in the Excel file.\n\nPlease check that your file contains valid product data.');
          }
        } catch (e) {
          // Make sure loading dialog is closed
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          rethrow;
        }
        
        if (products.isNotEmpty) {
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text('Confirm Import', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Found ${products.length} products to import.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will replace all existing products. Continue?',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Import', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
          );
          
          if (confirmed == true) {
            // Clear existing products and import new ones
            final existingProducts = await DatabaseService.getAllProducts();
            for (final product in existingProducts) {
              await DatabaseService.deleteProduct(product.id);
            }
            
            for (final product in products) {
              await DatabaseService.insertProduct(product);
            }
            
            // Refresh provider
            if (context.mounted) {
              await Provider.of<AppProvider>(context, listen: false).loadProducts();
            }
            
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text('Import Successful', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      '${products.length} products imported successfully!',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      textAlign: TextAlign.center,
                    ),
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
          }
        } else {
          throw Exception('No valid products found in Excel file');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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