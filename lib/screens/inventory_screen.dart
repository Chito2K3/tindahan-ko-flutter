import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../models/product.dart';
import '../services/barcode_service.dart';

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
    return Consumer2<AppProvider, ThemeProvider>(
      builder: (context, provider, themeProvider, child) {
        final theme = Theme.of(context);
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
                          color: theme.colorScheme.surface.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                      ),
                      child: IconButton(
                        onPressed: () => _showBarcodeScanner(context),
                        icon: Icon(Icons.qr_code_scanner, color: theme.colorScheme.primary),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
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
                        child: Text(
                          'Clear',
                          style: TextStyle(color: theme.colorScheme.primary),
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
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isEmpty 
                                    ? 'Add your first product using the + button'
                                    : 'Try a different search term',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
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
            backgroundColor: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    
    if (product != null) {
      // Product found - show details
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text('Product Found!', style: TextStyle(color: theme.colorScheme.onSurface)),
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
                          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₱${product.price.toStringAsFixed(2)}',
                          style: TextStyle(color: theme.colorScheme.primary, fontSize: 16),
                        ),
                        Text(
                          'Stock: ${product.stock}',
                          style: TextStyle(
                            color: product.isLowStock ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.7),
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
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editProduct(context, product);
              },
              child: Text('Edit', style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ],
        ),
      );
    } else {
      // Product not found - offer to add new
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text('Product Not Found', style: TextStyle(color: theme.colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              Text(
                'No product found with barcode:',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 8),
              Text(
                barcode,
                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addProductWithBarcode(context, barcode);
              },
              child: Text('Add Product', style: TextStyle(color: theme.colorScheme.primary)),
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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Delete Product', style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text(
          'Are you sure you want to delete "${product.name}"?',
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
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
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: product.isLowStock 
            ? Colors.red.withOpacity(0.1)
            : theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: product.isLowStock 
              ? Colors.red.withOpacity(0.5)
              : theme.colorScheme.outline.withOpacity(0.2),
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
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.displayPrice,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (product.isBatchSelling) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'BATCH',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (product.isCigarette) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'CIGARETTE',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (product.hasBarcode) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.qr_code,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                  product.isCigarette ? product.stockDisplay : '${product.stock}',
                  style: TextStyle(
                    color: product.isLowStock 
                        ? Colors.red
                        : theme.colorScheme.onSurface,
                    fontSize: product.isCigarette ? 14 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Stock',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                  icon: Icon(Icons.edit, color: theme.colorScheme.primary, size: 20),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning 
            ? Colors.orange.withOpacity(0.5)
            : theme.colorScheme.outline.withOpacity(0.2),
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
              color: isWarning ? Colors.orange : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
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
  final _scrollController = ScrollController();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _barcodeController;
  late TextEditingController _reorderController;
  late TextEditingController _batchQuantityController;
  late TextEditingController _batchPriceController;
  late TextEditingController _packPriceController;
  late TextEditingController _piecePriceController;
  
  String _selectedCategory = 'snacks';
  String _selectedEmoji = '📦';
  bool _hasBarcode = false;
  bool _isBatchSelling = false;
  bool _isCigarette = false;
  
  final List<String> _categories = ['snacks', 'drinks', 'household', 'personal', 'food', 'candies', 'cigarettes'];
  final List<String> _emojis = ['📦', '🍪', '🥤', '🍜', '🧽', '🦷', '🍞', '🥛', '🧴', '🍫', '🍬', '🚬'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _barcodeController = TextEditingController(text: widget.product?.barcode ?? widget.barcode ?? '');
    _reorderController = TextEditingController(text: widget.product?.reorderLevel.toString() ?? '5');
    _batchQuantityController = TextEditingController(text: widget.product?.batchQuantity?.toString() ?? '');
    _batchPriceController = TextEditingController(text: widget.product?.batchPrice?.toString() ?? '');
    _packPriceController = TextEditingController(text: widget.product?.packPrice?.toString() ?? '');
    _piecePriceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    
    if (widget.product != null) {
      _selectedCategory = widget.product!.category;
      _selectedEmoji = widget.product!.emoji;
      _hasBarcode = widget.product!.hasBarcode;
      _isBatchSelling = widget.product!.isBatchSelling;
      _isCigarette = widget.product!.isCigarette;
    } else if (widget.barcode != null) {
      _hasBarcode = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _barcodeController.dispose();
    _reorderController.dispose();
    _batchQuantityController.dispose();
    _batchPriceController.dispose();
    _packPriceController.dispose();
    _piecePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.product == null ? 'Add Product' : 'Edit Product',
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            DropdownButton<String>(
                              value: _selectedEmoji,
                              dropdownColor: theme.colorScheme.surface,
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
                                style: TextStyle(color: theme.colorScheme.onSurface),
                                decoration: InputDecoration(
                                  labelText: 'Product Name',
                                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
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
                            if (!_isBatchSelling && !_isCigarette)
                              Expanded(
                                child: TextFormField(
                                  controller: _priceController,
                                  style: TextStyle(color: theme.colorScheme.onSurface),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Price (₱)',
                                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (!_isBatchSelling && !_isCigarette && value?.isEmpty == true) return 'Required';
                                    if (!_isBatchSelling && !_isCigarette && double.tryParse(value!) == null) return 'Invalid number';
                                    return null;
                                  },
                                ),
                              ),
                            if (!_isBatchSelling && !_isCigarette) const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _stockController,
                                style: TextStyle(color: theme.colorScheme.onSurface),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Stock',
                                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
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
                                dropdownColor: theme.colorScheme.surface,
                                style: TextStyle(color: theme.colorScheme.onSurface),
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                                  ),
                                ),
                                items: _categories.map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                )).toList(),
                                onChanged: (value) => setState(() {
                                  _selectedCategory = value!;
                                  _isCigarette = value == 'cigarettes';
                                }),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _reorderController,
                                style: TextStyle(color: theme.colorScheme.onSurface),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Reorder Level',
                                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
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
                              activeColor: theme.colorScheme.primary,
                              onChanged: (value) => setState(() => _hasBarcode = value!),
                            ),
                            Text('Has Barcode', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                          ],
                        ),
                        if (_hasBarcode)
                          TextFormField(
                            controller: _barcodeController,
                            style: TextStyle(color: theme.colorScheme.onSurface),
                            decoration: InputDecoration(
                              labelText: 'Barcode',
                              labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _isBatchSelling,
                              activeColor: theme.colorScheme.primary,
                              onChanged: (value) => setState(() => _isBatchSelling = value!),
                            ),
                            Text('Batch Selling', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                          ],
                        ),
                        if (_isBatchSelling) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _batchQuantityController,
                                  style: TextStyle(color: theme.colorScheme.onSurface),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Batch Quantity',
                                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                                    ),
                                    hintText: 'e.g. 3',
                                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                  ),
                                  validator: (value) {
                                    if (_isBatchSelling && (value?.isEmpty == true)) return 'Required';
                                    if (_isBatchSelling && int.tryParse(value!) == null) return 'Invalid';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _batchPriceController,
                                  style: TextStyle(color: theme.colorScheme.onSurface),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Batch Price (₱)',
                                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                                    ),
                                    hintText: 'e.g. 5.00',
                                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                  ),
                                  validator: (value) {
                                    if (_isBatchSelling && (value?.isEmpty == true)) return 'Required';
                                    if (_isBatchSelling && double.tryParse(value!) == null) return 'Invalid';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Example: 3 pieces for ₱5.00',
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                          ),
                        ],
                        if (_isCigarette) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Cigarette Settings',
                            style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _piecePriceController,
                                  style: TextStyle(color: theme.colorScheme.onSurface),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Piece Price (₱)',
                                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                                    ),
                                    hintText: 'e.g. 6.50',
                                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                  ),
                                  validator: (value) {
                                    if (_isCigarette && (value?.isEmpty == true)) return 'Required';
                                    if (_isCigarette && double.tryParse(value!) == null) return 'Invalid number';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _packPriceController,
                                  style: TextStyle(color: theme.colorScheme.onSurface),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Pack Price (₱)',
                                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                                    ),
                                    hintText: 'e.g. 130.00',
                                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                  ),
                                  validator: (value) {
                                    if (_isCigarette && (value?.isEmpty == true)) return 'Required';
                                    if (_isCigarette && double.tryParse(value!) == null) return 'Invalid number';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Note: Stock represents total pieces. Piece Price is per individual cigarette, Pack Price is per pack (20 pieces).',
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.product == null ? 'Add' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      price: _isCigarette 
          ? double.parse(_piecePriceController.text)
          : (_isBatchSelling ? 0.0 : double.parse(_priceController.text)),
      stock: int.parse(_stockController.text),
      category: _selectedCategory,
      emoji: _selectedEmoji,
      reorderLevel: int.parse(_reorderController.text),
      hasBarcode: _hasBarcode,
      barcode: _hasBarcode ? _barcodeController.text : null,
      isBatchSelling: _isBatchSelling,
      batchQuantity: _isBatchSelling ? int.parse(_batchQuantityController.text) : null,
      batchPrice: _isBatchSelling ? double.parse(_batchPriceController.text) : null,
      isCigarette: _isCigarette,
      piecesPerPack: _isCigarette ? 20 : null,
      packPrice: _isCigarette ? double.parse(_packPriceController.text) : null,
      loosePieces: _isCigarette ? int.parse(_stockController.text) % 20 : 0,
      fullPacks: _isCigarette ? int.parse(_stockController.text) ~/ 20 : 0,
      autoOpenPack: _isCigarette ? true : false,
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
          backgroundColor: Theme.of(context).colorScheme.primary,
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