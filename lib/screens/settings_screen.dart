import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/app_provider.dart';
import '../services/database_service.dart';
import '../models/product.dart';
import '../utils/theme.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';
import 'package:universal_html/html.dart' as html;

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onStoreInfoUpdated;
  
  const SettingsScreen({super.key, this.onStoreInfoUpdated});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white70,
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
      backgroundColor: Colors.grey[900],
      title: const Text('Store Information', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 300,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _storeNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Store Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              TextFormField(
                controller: _ownerNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Owner Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              TextFormField(
                controller: _addressController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
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
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        TextButton(
          onPressed: _saveStoreInfo,
          child: const Text('Save', style: TextStyle(color: AppTheme.primaryPink)),
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
      const SnackBar(
        content: Text('Store information saved'),
        backgroundColor: AppTheme.primaryPink,
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
      backgroundColor: Colors.grey[900],
      title: const Text('Backup & Restore', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.upload, color: AppTheme.primaryPink),
            title: const Text('Export to Excel', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Download products as .xlsx file', style: TextStyle(color: Colors.white70)),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: AppTheme.primaryPink),
            title: const Text('Import from Excel', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Upload .xlsx file to restore products', style: TextStyle(color: Colors.white70)),
            onTap: () => _importData(context),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
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
      if (kIsWeb) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement()
          ..href = url
          ..style.display = 'none'
          ..download = 'tindahan_ko_products.xlsx';
        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);
      }
      
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Export Successful', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text('Products exported to Excel successfully!', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Text('${products.length} products exported', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('File: tindahan_ko_products.xlsx', style: TextStyle(color: Colors.pink, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: AppTheme.primaryPink)),
            ),
          ],
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
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );
      
      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final excel = Excel.decodeBytes(bytes);
        
        final sheet = excel.tables['Products'];
        if (sheet == null) {
          throw Exception('No "Products" sheet found in Excel file');
        }
        
        final products = <Product>[];
        
        // Skip header row, start from row 1 (0-indexed)
        for (int i = 1; i < sheet.maxRows; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty || row[1]?.value == null) continue;
          
          final id = row[0]?.value?.toString() ?? const Uuid().v4();
          final name = row[1]?.value?.toString() ?? '';
          final price = double.tryParse(row[2]?.value?.toString() ?? '0') ?? 0.0;
          final stock = int.tryParse(row[3]?.value?.toString() ?? '0') ?? 0;
          final category = row[4]?.value?.toString() ?? 'General';
          final emoji = row[5]?.value?.toString() ?? '📦';
          final reorderLevel = int.tryParse(row[6]?.value?.toString() ?? '5') ?? 5;
          final hasBarcode = row[7]?.value?.toString().toUpperCase() == 'YES';
          final barcode = row[8]?.value?.toString();
          
          if (name.isNotEmpty) {
            products.add(Product(
              id: id,
              name: name,
              price: price,
              stock: stock,
              category: category,
              emoji: emoji,
              reorderLevel: reorderLevel,
              hasBarcode: hasBarcode,
              barcode: barcode?.isEmpty == true ? null : barcode,
            ));
          }
        }
        
        if (products.isNotEmpty) {
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text('Confirm Import', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Found ${products.length} products to import.',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This will replace all existing products. Continue?',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Import', style: TextStyle(color: AppTheme.primaryPink)),
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
                backgroundColor: Colors.grey[900],
                title: const Text('Import Successful', style: TextStyle(color: Colors.white)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      '${products.length} products imported successfully!',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK', style: TextStyle(color: AppTheme.primaryPink)),
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
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryPink, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('About', style: TextStyle(color: Colors.white, fontSize: 20)),
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
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                        style: const TextStyle(
                          color: AppTheme.primaryPink,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Para sa mga Reyna ng Tahanan 👑',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'Version 1.0.0',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'A complete Point of Sale and Inventory Management System designed specifically for Filipino sari-sari stores.',
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryPink.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryPink.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.code, color: AppTheme.primaryPink, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Developer',
                        style: TextStyle(
                          color: AppTheme.primaryPink,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Chito Saba',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'chitosaba@gmail.com',
                        style: TextStyle(
                          color: AppTheme.primaryPink,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Key Features:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text('📱 Native barcode scanning', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const Text('💰 Point of Sale system', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const Text('📦 Inventory management', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const Text('📊 Sales tracking', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const Text('💾 Data backup & restore', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '© 2024 Chito Saba. All rights reserved.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
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
          child: const Text(
            'Close',
            style: TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}