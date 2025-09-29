import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/barcode_service.dart';
import '../utils/theme.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';

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
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.search, color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                  12.widthBox,
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
              ).py16(),
              
              // Categories
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CategoryChip('all', 'All', _selectedCategory == 'all'),
                    _CategoryChip('snacks', 'Snacks', _selectedCategory == 'snacks'),
                    _CategoryChip('drinks', 'Drinks', _selectedCategory == 'drinks'),
                    _CategoryChip('household', 'Household', _selectedCategory == 'household'),
                    _CategoryChip('personal', 'Personal', _selectedCategory == 'personal'),
                  ].map((chip) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = chip.category),
                      child: chip,
                    ),
                  )).toList(),
                ),
              ).py16(),
              
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
                      16.heightBox,
                      
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
                                      12.widthBox,
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
                                              '₱${item.product.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          _QuantityButton(
                                            icon: Icons.remove,
                                            onPressed: () => provider.updateCartQuantity(index, -1),
                                          ),
                                          8.widthBox,
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          8.widthBox,
                                          _QuantityButton(
                                            icon: Icons.add,
                                            onPressed: () => provider.updateCartQuantity(index, 1),
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
                              '₱${provider.cartTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryPink,
                              ),
                            ),
                          ],
                        ),
                        16.heightBox,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful! 🎉'),
        content: Text('Total: ₱${provider.cartTotal.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () {
              provider.completeSale();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  final String label;
  final bool isSelected;

  const _CategoryChip(this.category, this.label, this.isSelected);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryPink : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppTheme.primaryPink : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
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