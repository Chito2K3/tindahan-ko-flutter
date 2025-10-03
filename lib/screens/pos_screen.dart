import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../models/product.dart';
import '../services/barcode_service.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchResults = false;
  List<Product> _searchResults = [];
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      return;
    }
    
    final provider = Provider.of<AppProvider>(context, listen: false);
    final results = provider.products.where((product) {
      return product.name.toLowerCase().contains(query) ||
             product.category.toLowerCase().contains(query) ||
             (product.barcode?.contains(query) ?? false);
    }).toList();
    
    setState(() {
      _showSearchResults = true;
      _searchResults = results;
    });
  }
  
  void _selectProduct(Product product) {
    if (product.isCigarette || product.category == 'cigarettes') {
      _showCigaretteSelectionDialog(product);
    } else {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.addToCart(product);
      _searchController.clear();
      _searchFocusNode.unfocus();
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added to cart!')),
      );
    }
  }

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
              // Search and Scan
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: TextStyle(color: theme.colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                              prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _showSearchResults = false;
                                          _searchResults = [];
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _scanBarcode(context, provider),
                          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  // Search Results Dropdown
                  if (_showSearchResults)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: _searchResults.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.search_off, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Item doesn\'t exist',
                                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final product = _searchResults[index];
                                return ListTile(
                                  leading: Text(
                                    product.emoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  title: Text(
                                    product.name,
                                    style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    product.displayPrice,
                                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 12),
                                  ),
                                  trailing: Text(
                                    'Stock: ${product.stock}',
                                    style: TextStyle(
                                      color: product.isLowStock ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  onTap: () => _selectProduct(product),
                                );
                              },
                            ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Cart Section
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cart',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (provider.cart.isNotEmpty)
                            TextButton(
                              onPressed: provider.clearCart,
                              child: Text(
                                'Clear',
                                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Cart Items
                      Expanded(
                        child: provider.cart.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🛒', style: TextStyle(fontSize: 48)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Cart is empty',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Scan or search for products',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withOpacity(0.54),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: provider.cart.length,
                              itemBuilder: (context, index) {
                                final item = provider.cart[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        item.product.emoji,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name,
                                              style: TextStyle(
                                                color: theme.colorScheme.onSurface,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '₱${item.totalPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (item.product.isBatchSelling)
                                              Text(
                                                'Batch: ${item.product.batchQuantity}pcs = ₱${item.product.batchPrice!.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: theme.colorScheme.primary,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            if (item.product.isCigarette || item.product.category == 'cigarettes') ...[
                                              Text(
                                                item.displayQuantity,
                                                style: TextStyle(
                                                  color: theme.colorScheme.primary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => provider.toggleCigaretteMode(index),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.primary.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: theme.colorScheme.primary, width: 0.5),
                                                  ),
                                                  child: Text(
                                                    item.isPackMode ? 'Pack Mode' : 'Piece Mode',
                                                    style: TextStyle(
                                                      color: theme.colorScheme.primary,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          _QuantityButton(
                                            icon: Icons.remove,
                                            onPressed: () => _updateQuantity(provider, index, -1, _getIncrement(item)),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${item.quantity}',
                                            style: TextStyle(
                                              color: theme.colorScheme.onSurface,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _QuantityButton(
                                            icon: Icons.add,
                                            onPressed: () => _updateQuantity(provider, index, 1, _getIncrement(item)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      ),
                      
                      // Total and Checkout
                      if (provider.cart.isNotEmpty) ...[
                        Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '₱${provider.cartTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _processPayment(context, provider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Text(
                              'Process Payment 💳',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCigaretteSelectionDialog(Product product) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Row(
          children: [
            Text(product.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                product.name,
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose how to add to cart:',
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _addCigaretteToCart(product, CigaretteUnit.piece);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.scatter_plot, size: 16),
                    label: Column(
                      children: [
                        const Text('Piece', style: TextStyle(fontSize: 12)),
                        Text('₱${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _addCigaretteToCart(product, CigaretteUnit.pack);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.inventory_2, size: 16),
                    label: Column(
                      children: [
                        const Text('Pack', style: TextStyle(fontSize: 12)),
                        Text('₱${(product.packPrice ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
        ],
      ),
    );
  }

  void _addCigaretteToCart(Product product, CigaretteUnit unit) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final isPackMode = unit == CigaretteUnit.pack;
    provider.addToCart(product, isPackMode: isPackMode);
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _showSearchResults = false;
      _searchResults = [];
    });
    final unitText = unit == CigaretteUnit.piece ? 'piece' : 'pack';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} ($unitText) added to cart!')),
    );
  }

  void _scanBarcode(BuildContext context, AppProvider provider) async {
    final hasPermission = await BarcodeService.requestCameraPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission required')),
      );
      return;
    }

    BarcodeService.showBarcodeScanner(
      context,
      onBarcodeDetected: (barcode) {
        final product = provider.findProductByBarcode(barcode);
        if (product != null) {
          if (product.isCigarette || product.category == 'cigarettes') {
            _showCigaretteSelectionDialog(product);
          } else {
            provider.addToCart(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.name} added to cart!')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product not found: $barcode')),
          );
        }
      },
    );
  }

  void _processPayment(BuildContext context, AppProvider provider) {
    final TextEditingController paymentController = TextEditingController();
    final theme = Theme.of(context);
    double totalAmount = provider.cartTotal;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          double paymentAmount = double.tryParse(paymentController.text) ?? 0.0;
          double change = paymentAmount - totalAmount;
          bool isValidPayment = paymentAmount >= totalAmount;
          
          return AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            title: Row(
              children: [
                Icon(Icons.payment, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Process Payment', style: TextStyle(color: theme.colorScheme.onSurface)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary:',
                    style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: SingleChildScrollView(
                      child: Column(
                        children: provider.cart.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  (item.product.isCigarette || item.product.category == 'cigarettes') 
                                      ? '${item.product.emoji} ${item.product.name} (${item.isPackMode ? 'Pack' : 'Piece'}) x${item.quantity}'
                                      : '${item.product.emoji} ${item.product.name} x${item.quantity}',
                                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 12),
                                ),
                              ),
                              Text(
                                '₱${item.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 12),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '₱${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Amount:',
                    style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: paymentController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Enter payment amount',
                        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.54)),
                        prefixText: '₱',
                        prefixStyle: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (paymentAmount > 0) ...[
                    if (isValidPayment) ...[
                      if (change > 0) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Change:',
                                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₱${change.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.5)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Exact payment',
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Insufficient payment',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Need ₱${(totalAmount - paymentAmount).toStringAsFixed(2)} more',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
              ),
              ElevatedButton(
                onPressed: isValidPayment && paymentAmount > 0 
                    ? () => _confirmPayment(context, provider, paymentAmount, change)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValidPayment && paymentAmount > 0 
                      ? theme.colorScheme.primary 
                      : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm Payment'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  int _getIncrement(CartItem item) {
    if (item.product.isBatchSelling) return item.product.batchQuantity!;
    if ((item.product.isCigarette || item.product.category == 'cigarettes') && item.isPackMode) return item.product.piecesPerPack ?? 20;
    return 1;
  }
  
  void _updateQuantity(AppProvider provider, int index, int change, int increment) {
    final message = provider.updateCartQuantityByIncrement(index, change, increment);
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
  
  void _confirmPayment(BuildContext context, AppProvider provider, double paymentAmount, double change) async {
    final theme = Theme.of(context);
    Navigator.pop(context); // Close confirmation dialog
    
    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Processing payment...',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
    
    try {
      // Store total amount before clearing cart
      double totalAmount = provider.cartTotal;
      
      // Complete the sale
      await provider.completeSale();
      
      // Close processing dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Show success dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Text('Payment Successful!', style: TextStyle(color: theme.colorScheme.onSurface)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Total: ₱${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment: ₱${paymentAmount.toStringAsFixed(2)}',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
                ),
                if (change > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Change: ₱${change.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Transaction completed successfully!',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${DateTime.now().toString().split('.')[0]}',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sale completed successfully! 🎉'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close processing dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            title: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text('Payment Failed', style: TextStyle(color: theme.colorScheme.onSurface)),
              ],
            ),
            content: Text(
              'Error: $e\n\nPlease try again.',
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ],
          ),
        );
      }
    }
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: Colors.white),
        padding: EdgeInsets.zero,
      ),
    );
  }
}