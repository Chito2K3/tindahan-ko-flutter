import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/product.dart';
import '../models/sale.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.pink,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Sales Report'),
              Tab(text: 'Inventory Report'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSalesReport(),
                _buildInventoryReport(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesReport() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildSalesChart(provider.sales),
              const SizedBox(height: 20),
              _buildTopSellingItems(provider.sales),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryReport() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildInventoryStats(provider.products),
              const SizedBox(height: 20),
              _buildLowStockAlerts(provider.products),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalesChart(List<Sale> sales) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Sales (Last 7 Days)',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: sales.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('📈', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 16),
                      Text(
                        'No sales data yet',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        'Complete some sales to see the chart',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return Text(
                          days[value.toInt() % 7],
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateSalesData(sales),
                    isCurved: true,
                    color: Colors.pink,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.pink.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingItems(List<Sale> sales) {
    final topItems = _generateTopSellingItems(sales);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Selling Items',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (topItems.isEmpty)
            const Center(
              child: Column(
                children: [
                  Text('📊', style: TextStyle(fontSize: 32)),
                  SizedBox(height: 8),
                  Text(
                    'No sales data yet',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Complete some sales to see top selling items',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ...topItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(item['emoji'], style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${item['sold']} sold',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₱${NumberFormat('#,##0.00').format(item['revenue'])}',
                    style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildInventoryStats(List<Product> products) {
    final totalProducts = products.length;
    final totalValue = products.fold<double>(0, (sum, p) => sum + (p.price * p.stock));
    final lowStockCount = products.where((p) => p.stock <= p.reorderLevel).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Overview',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Products', totalProducts.toString(), '📦'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Total Value', '₱${NumberFormat('#,##0').format(totalValue)}', '💰'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Low Stock', lowStockCount.toString(), '⚠️'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Categories', _getUniqueCategories(products).toString(), '🏷️'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlerts(List<Product> products) {
    final lowStockProducts = products.where((p) => p.stock <= p.reorderLevel).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Low Stock Alerts',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${lowStockProducts.length}',
                  style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (lowStockProducts.isEmpty)
            const Center(
              child: Column(
                children: [
                  Text('✅', style: TextStyle(fontSize: 32)),
                  SizedBox(height: 8),
                  Text(
                    'All products are well stocked!',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          else
            ...lowStockProducts.map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(product.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Stock: ${product.stock} (Reorder at: ${product.reorderLevel})',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LOW',
                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  List<FlSpot> _generateSalesData(List<Sale> sales) {
    if (sales.isEmpty) {
      return [const FlSpot(0, 0)];
    }
    
    // Group sales by day for the last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
    
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      final day = last7Days[i];
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final daySales = sales.where((sale) => 
        sale.date.isAfter(dayStart) && sale.date.isBefore(dayEnd)
      ).toList();
      
      final dayTotal = daySales.fold<double>(0, (sum, sale) => sum + sale.total);
      spots.add(FlSpot(i.toDouble(), dayTotal));
    }
    
    return spots;
  }

  List<Map<String, dynamic>> _generateTopSellingItems(List<Sale> sales, List<Product> products) {
    if (sales.isEmpty) {
      return [];
    }
    
    // Create a map for quick product lookup
    final productMap = {for (var p in products) p.id: p};
    
    // Aggregate sales by product
    Map<String, Map<String, dynamic>> productSales = {};
    
    for (final sale in sales) {
      for (final item in sale.items) {
        final product = productMap[item.productId];
        final emoji = product?.emoji ?? '📦';
        
        if (productSales.containsKey(item.productId)) {
          productSales[item.productId]!['sold'] += item.quantity;
          productSales[item.productId]!['revenue'] += item.total;
        } else {
          productSales[item.productId] = {
            'name': item.productName,
            'emoji': emoji,
            'sold': item.quantity,
            'revenue': item.total,
          };
        }
      }
    }
    
    // Sort by revenue and take top 5
    final sortedItems = productSales.values.toList()
      ..sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));
    
    return sortedItems.take(5).toList();
  }

  int _getUniqueCategories(List<Product> products) {
    return products.map((p) => p.category).toSet().length;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}