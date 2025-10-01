import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/product.dart';
import '../services/barcode_service.dart';
import '../utils/theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
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
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              hintStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.search, color: Colors.white70),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.white70),
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
                          color: AppTheme.primaryPink,
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
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: _searchResults.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              child: const Row(
                                children: [
                                  Icon(Icons.search_off, color: Colors.white70),
                                  SizedBox(width: 12),
                                  Text(
                                    'Item doesn\'t exist',
                                    style: TextStyle(color: Colors.white70),
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
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    product.displayPrice,
                                    style: const TextStyle(color: AppTheme.primaryPink, fontSize: 12),
                                  ),
                                  trailing: Text(
                                    'Stock: ${product.stock}',
                                    style: TextStyle(
                                      color: product.isLowStock ? Colors.red : Colors.white70,
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
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cart',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (provider.cart.isNotEmpty)
                            TextButton(
                              onPressed: provider.clearCart,
                              child: const Text(
                                'Clear',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Cart Items
                      Expanded(
                        child: provider.cart.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('🛒', style: TextStyle(fontSize: 48)),
                                  SizedBox(height: 16),
                                  Text(
                                    'Cart is empty',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Scan or search for products',
                                    style: TextStyle(
                                      color: Colors.white54,
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
                                    color: Colors.white.withOpacity(0.1),
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
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              AppTheme.formatCurrency(item.product.getPriceForQuantity(item.quantity, isPackMode: item.isPackMode)),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (item.product.isBatchSelling)
                                              Text(
                                                'Batch: ${item.product.batchQuantity}pcs = ${AppTheme.formatCurrency(item.product.batchPrice!)}',
                                                style: const TextStyle(
                                                  color: AppTheme.primaryPink,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            if (item.product.isCigarette)
                                              GestureDetector(
                                                onTap: () => provider.toggleCigaretteMode(index),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primaryPink.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: AppTheme.primaryPink, width: 0.5),
                                                  ),
                                                  child: Text(
                                                    item.isPackMode ? 'Pack Mode' : 'Piece Mode',
                                                    style: const TextStyle(
                                                      color: AppTheme.primaryPink,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
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
                                            style: const TextStyle(
                                              color: Colors.white,
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
                        const Divider(color: Colors.white30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              AppTheme.formatCurrency(provider.cartTotal),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryPink,
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
                              backgroundColor: AppTheme.primaryPink,
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
          provider.addToCart(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} added to cart!')),
          );
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
            backgroundColor: Colors.grey[900],
            title: const Row(
              children: [
                Icon(Icons.payment, color: AppTheme.primaryPink),
                SizedBox(width: 8),
                Text('Process Payment', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary:',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                                  '${item.product.emoji} ${item.product.name} x${item.quantity}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ),
                              Text(
                                AppTheme.formatCurrency(item.product.getPriceForQuantity(item.quantity, isPackMode: item.isPackMode)),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        AppTheme.formatCurrency(totalAmount),
                        style: const TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment Amount:',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: paymentController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Enter payment amount',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixText: '₱',
                        prefixStyle: const TextStyle(color: Colors.white, fontSize: 16),
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
                              const Text(
                                'Change:',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                AppTheme.formatCurrency(change),
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
                              'Need ${AppTheme.formatCurrency(totalAmount - paymentAmount)} more',
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
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: isValidPayment && paymentAmount > 0 
                    ? () => _confirmPayment(context, provider, paymentAmount, change)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValidPayment && paymentAmount > 0 
                      ? AppTheme.primaryPink 
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
    if (item.product.isCigarette && item.isPackMode) return item.product.piecesPerPack!;
    return 1;
  }
  
  void _updateQuantity(AppProvider provider, int index, int change, int increment) {
    provider.updateCartQuantityByIncrement(index, change, increment);
  }
  
  void _confirmPayment(BuildContext context, AppProvider provider, double paymentAmount, double change) async {
    Navigator.pop(context); // Close confirmation dialog
    
    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryPink),
            const SizedBox(height: 16),
            const Text(
              'Processing payment...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
    
    try {
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 2));
      
      double totalAmount = provider.cartTotal;
      await provider.completeSale();
      
      Navigator.pop(context); // Close processing dialog
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('Payment Successful!', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Total: ${AppTheme.formatCurrency(totalAmount)}',
                style: const TextStyle(color: AppTheme.primaryPink, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Payment: ${AppTheme.formatCurrency(paymentAmount)}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (change > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Change: ${AppTheme.formatCurrency(change)}',
                  style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Transaction completed successfully!',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${DateTime.now().toString().split('.')[0]}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
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
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close processing dialog
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Payment Failed', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'Error: $e\n\nPlease try again.',
            style: const TextStyle(color: Colors.white70),
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
        color: AppTheme.primaryPink,
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