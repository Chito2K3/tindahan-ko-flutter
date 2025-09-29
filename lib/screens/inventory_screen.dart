import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Padding(
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
                  12.widthBox,
                  Expanded(
                    child: _StatCard(
                      title: 'Low Stock',
                      value: '${provider.lowStockCount}',
                      icon: '⚠️',
                      isWarning: provider.lowStockCount > 0,
                    ),
                  ),
                ],
              ).py16(),
              
              // Products List
              const Text(
                'Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).py8(),
              
              Expanded(
                child: ListView.builder(
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: product.isLowStock 
                            ? Colors.orange.withOpacity(0.5)
                            : Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            product.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          16.widthBox,
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
                                4.heightBox,
                                Row(
                                  children: [
                                    Text(
                                      '₱${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppTheme.primaryPink,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    8.widthBox,
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
                                      8.widthBox,
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
                                    ? Colors.orange
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
                                4.heightBox,
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'LOW',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
          8.heightBox,
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.orange : Colors.white,
            ),
          ),
          4.heightBox,
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