import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/product.dart';
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
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSalesChart(),
          const SizedBox(height: 20),
          _buildTopSellingItems(),
        ],
      ),
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

  Widget _buildSalesChart() {
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
            child: LineChart(
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
                    spots: _generateSampleSalesData(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingItems() {
    final topItems = _generateTopSellingItems();
    
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

  List<FlSpot> _generateSampleSalesData() {
    return [
      const FlSpot(0, 1200),
      const FlSpot(1, 1800),
      const FlSpot(2, 1500),
      const FlSpot(3, 2200),
      const FlSpot(4, 1900),
      const FlSpot(5, 2500),
      const FlSpot(6, 2100),
    ];
  }

  List<Map<String, dynamic>> _generateTopSellingItems() {
    return [
      {'name': 'Rice 5kg', 'emoji': '🍚', 'sold': 45, 'revenue': 11250.0},
      {'name': 'Instant Noodles', 'emoji': '🍜', 'sold': 38, 'revenue': 570.0},
      {'name': 'Cooking Oil', 'emoji': '🫒', 'sold': 25, 'revenue': 3750.0},
      {'name': 'Canned Goods', 'emoji': '🥫', 'sold': 22, 'revenue': 1100.0},
      {'name': 'Soft Drinks', 'emoji': '🥤', 'sold': 18, 'revenue': 720.0},
    ];
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