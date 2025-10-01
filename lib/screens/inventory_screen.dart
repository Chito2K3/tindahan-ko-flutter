import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/product.dart';
import '../services/barcode_service.dart';
import '../utils/theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    if (_searchQuery.isEmpty) return products;
    return products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             product.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (product.barcode?.contains(_searchQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final filteredProducts = _getFilteredProducts(provider.products);
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Products',
                        value: '${provider.totalProducts}',
                        icon: '📦',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Low Stock',
                        value: '${provider.lowStockCount}',
                        icon: '⚠️',
                        isWarning: provider.lowStockCount > 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Search Bar and Barcode Scanner
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: TextStyle(color: Colors.white60),
                            prefixIcon: Icon(Icons.search, color: Colors.white60),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPink.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryPink.withOpacity(0.3)),
                      ),
                      child: IconButton(
                        onPressed: () => _showBarcodeScanner(context),
                        icon: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryPink),
                        tooltip: 'Scan Barcode',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Products List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Products (${filteredProducts.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: AppTheme.primaryPink),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Products List
                Expanded(
                  child: filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '📦',
                                style: TextStyle(fontSize: 64),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty ? 'No products yet' : 'No products found',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isEmpty 
                                    ? 'Add your first product using the + button'
                                    : 'Try a different search term',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return _ProductCard(
                              product: product,
                              onEdit: () => _editProduct(context, product),
                              onDelete: () => _deleteProduct(context, product),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addProduct(context),
            backgroundColor: AppTheme.primaryPink,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Item',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  void _showBarcodeScanner(BuildContext context) {
    BarcodeService.showBarcodeScanner(
      context,
      title: 'Scan Product Barcode',
      onBarcodeDetected: (barcode) {
        _handleScannedBarcode(context, barcode);
      },
    );
  }
  
  void _handleScannedBarcode(BuildContext context, String barcode) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final product = provider.findProductByBarcode(barcode);
    
    if (product != null) {
      // Product found - show details
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Product Found!', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(product.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₱${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppTheme.primaryPink, fontSize: 16),
                        ),
                        Text(
                          'Stock: ${product.stock}',
                          style: TextStyle(
                            color: product.isLowStock ? Colors.red : Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Barcode: $barcode',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editProduct(context, product);
              },
              child: const Text('Edit', style: TextStyle(color: AppTheme.primaryPink)),
            ),
          ],
        ),
      );
    } else {
      // Product not found - offer to add new
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Product Not Found', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              Text(
                'No product found with barcode:',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                barcode,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addProductWithBarcode(context, barcode);
              },
              child: const Text('Add Product', style: TextStyle(color: AppTheme.primaryPink)),
            ),
          ],
        ),
      );
    }
  }
  
  void _addProductWithBarcode(BuildContext context, String barcode) {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(barcode: barcode),
    );
  }

  void _addProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(),
    );
  }

  void _editProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(product: product),
    );
  }

  void _deleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Product', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${product.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Provider.of<AppProvider>(context, listen: false).deleteProduct(product.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting product: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: product.isLowStock 
            ? Colors.red.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: product.isLowStock 
              ? Colors.red.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
          width: product.isLowStock ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              product.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₱${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.primaryPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (product.hasBarcode) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.qr_code,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${product.stock}',
                  style: TextStyle(
                    color: product.isLowStock 
                        ? Colors.red
                        : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Stock',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                if (product.isLowStock) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'LOW STOCK',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: AppTheme.primaryPink, size: 20),
                  tooltip: 'Edit',
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  tooltip: 'Delete',
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String icon;
  final bool isWarning;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning 
            ? Colors.orange.withOpacity(0.5)
            : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.orange : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final Product? product;
  final String? barcode;

  const _ProductDialog({this.product, this.barcode});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _barcodeController;
  late TextEditingController _reorderController;
  
  String _selectedCategory = 'snacks';
  String _selectedEmoji = '📦';
  bool _hasBarcode = false;
  
  final List<String> _categories = ['snacks', 'drinks', 'household', 'personal', 'food'];
  final List<String> _emojis = ['📦', '🍪', '🥤', '🍜', '🧽', '🦷', '🍞', '🥛', '🧴', '🍫'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _barcodeController = TextEditingController(text: widget.product?.barcode ?? widget.barcode ?? '');
    _reorderController = TextEditingController(text: widget.product?.reorderLevel.toString() ?? '5');
    
    if (widget.product != null) {
      _selectedCategory = widget.product!.category;
      _selectedEmoji = widget.product!.emoji;
      _hasBarcode = widget.product!.hasBarcode;
    } else if (widget.barcode != null) {
      _hasBarcode = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _barcodeController.dispose();
    _reorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        widget.product == null ? 'Add Product' : 'Edit Product',
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 300,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedEmoji,
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(fontSize: 24),
                      items: _emojis.map((emoji) => DropdownMenuItem(
                        value: emoji,
                        child: Text(emoji),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedEmoji = value!),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Price (₱)',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Required';
                          if (double.tryParse(value!) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stock',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Required';
                          if (int.tryParse(value!) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                        items: _categories.map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedCategory = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _reorderController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Reorder Level',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Required';
                          if (int.tryParse(value!) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _hasBarcode,
                      activeColor: AppTheme.primaryPink,
                      onChanged: (value) => setState(() => _hasBarcode = value!),
                    ),
                    const Text('Has Barcode', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                if (_hasBarcode)
                  TextFormField(
                    controller: _barcodeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Barcode',
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        TextButton(
          onPressed: _saveProduct,
          child: Text(
            widget.product == null ? 'Add' : 'Save',
            style: const TextStyle(color: AppTheme.primaryPink),
          ),
        ),
      ],
    );
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      price: double.parse(_priceController.text),
      stock: int.parse(_stockController.text),
      category: _selectedCategory,
      emoji: _selectedEmoji,
      reorderLevel: int.parse(_reorderController.text),
      hasBarcode: _hasBarcode,
      barcode: _hasBarcode ? _barcodeController.text : null,
    );

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (widget.product == null) {
        await provider.addProduct(product);
      } else {
        await provider.updateProduct(product);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ${widget.product == null ? 'added' : 'updated'}'),
          backgroundColor: AppTheme.primaryPink,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}