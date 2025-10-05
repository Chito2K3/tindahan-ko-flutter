import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/barcode_service.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Daily';
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchResults = false;
  List<Product> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
    return Consumer2<AppProvider, ThemeProvider>(
      builder: (context, provider, themeProvider, child) {
        final theme = Theme.of(context);
        final filteredSales = _getFilteredSales(provider.sales);
        
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildPeriodSelector(theme),
              const SizedBox(height: 20),
              _buildSalesChart(filteredSales),
              const SizedBox(height: 20),
              _buildTopSellingItems(filteredSales),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryReport() {
    return Consumer2<AppProvider, ThemeProvider>(
      builder: (context, provider, themeProvider, child) {
        final theme = Theme.of(context);
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildInventoryOverview(provider, theme),
              const SizedBox(height: 20),
              _buildInventorySearchBar(provider, theme),
              const SizedBox(height: 20),
              _buildLowStockAlerts(provider.products),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalesChart(List<Sale> sales) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final totalSales = sales.fold<double>(0, (sum, sale) => sum + sale.total);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_selectedPeriod} Sales',
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      '₱${NumberFormat('#,##0.00').format(totalSales)}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPeriodDescription(),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (sales.isEmpty) ...[
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      const Text('📈', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        'No sales found',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 16),
                      ),
                      Text(
                        _getNoSalesMessage(),
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.54), fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        );
      }
    );
  }

  Widget _buildTopSellingItems(List<Sale> sales) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final topItems = _generateTopSellingItems(sales, context.read<AppProvider>().products);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Selling Items',
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (topItems.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const Text('📊', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        'No sales data yet',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      Text(
                        'Complete some sales to see top selling items',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.54), fontSize: 12),
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
                              style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${item['sold']} sold',
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₱${NumberFormat('#,##0.00').format(item['revenue'])}',
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
            ],
          ),
        );
      }
    );
  }

  Widget _buildInventoryOverview(AppProvider provider, ThemeData theme) {
    final totalProducts = provider.products.length;
    final totalValue = provider.products.fold<double>(0, (sum, p) => sum + (p.price * p.stock));
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Overview',
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
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
                child: GestureDetector(
                  onTap: () => _showLowStockDetails(context, provider),
                  child: _buildStatCard('Low Stock', provider.lowStockCount.toString(), '⚠️', isClickable: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showOutOfStockDetails(context, provider),
                  child: _buildStatCard('Out of Stock', provider.outOfStockCount.toString(), '❌', isClickable: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String emoji, {bool isClickable = false}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isClickable 
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: isClickable ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              if (isClickable)
                Icon(
                  Icons.touch_app,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                  size: 16,
                ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildLowStockAlerts(List<Product> products) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final lowStockProducts = products.where((p) => p.stock <= p.reorderLevel).toList();
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Low Stock Alerts',
                    style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
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
                Center(
                  child: Column(
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        'All products are well stocked!',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
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
                              style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Stock: ${product.stock} (Reorder at: ${product.reorderLevel})',
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 12),
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
    
    // Aggregate sales by product name (including cigarette mode)
    Map<String, Map<String, dynamic>> productSales = {};
    
    for (final sale in sales) {
      for (final item in sale.items) {
        final product = productMap[item.productId];
        final emoji = product?.emoji ?? '📦';
        final key = item.productName; // Use full product name as key (includes Pack/Stick for cigarettes)
        
        // Calculate correct revenue: quantity * individual price
        final revenue = item.quantity * item.price;
        
        if (productSales.containsKey(key)) {
          productSales[key]!['sold'] += item.quantity;
          productSales[key]!['revenue'] += revenue;
        } else {
          productSales[key] = {
            'name': item.productName,
            'emoji': emoji,
            'sold': item.quantity,
            'revenue': revenue,
          };
        }
      }
    }
    
    // Sort by revenue and take top 5
    final sortedItems = productSales.values.toList()
      ..sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));
    
    return sortedItems.take(5).toList();
  }

  Widget _buildInventorySearchBar(AppProvider provider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Lookup',
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
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
                        focusNode: _searchFocusNode,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search product stock...',
                          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.6)),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
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
                      onPressed: () => _scanForStock(context, provider),
                      icon: Icon(Icons.qr_code_scanner, color: theme.colorScheme.primary),
                      tooltip: 'Scan for Stock',
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
                                'Product not found',
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.displayPrice,
                                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 12),
                                  ),
                                  Text(
                                    product.category,
                                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 11),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _getStockDisplay(product),
                                    style: TextStyle(
                                      color: product.isOutOfStock
                                          ? Colors.red
                                          : product.isLowStock
                                              ? Colors.orange
                                              : theme.colorScheme.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Stock',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                                setState(() {
                                  _showSearchResults = false;
                                  _searchResults = [];
                                });
                                _showStockResults(context, [product], 'Stock Info - ${product.name}');
                              },
                            );
                          },
                        ),
                ),
            ],
          ),
        ],
      ),
    );
  }



  void _scanForStock(BuildContext context, AppProvider provider) {
    BarcodeService.showBarcodeScanner(
      context,
      title: 'Scan for Stock Info',
      onBarcodeDetected: (barcode) {
        final product = provider.findProductByBarcode(barcode);
        if (product != null) {
          _showStockResults(context, [product], 'Stock Info');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product not found: $barcode')),
          );
        }
      },
    );
  }

  void _showStockResults(BuildContext context, List<Product> products, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _StockResultsScreen(products: products, title: title),
        fullscreenDialog: true,
      ),
    );
  }

  void _showLowStockDetails(BuildContext context, AppProvider provider) {
    final lowStockProducts = provider.products.where((p) => p.isLowStock && !p.isOutOfStock).toList();
    _showStockResults(context, lowStockProducts, 'Low Stock Items');
  }

  void _showOutOfStockDetails(BuildContext context, AppProvider provider) {
    final outOfStockProducts = provider.products.where((p) => p.isOutOfStock).toList();
    _showStockResults(context, outOfStockProducts, 'Out of Stock Items');
  }

  int _getUniqueCategories(List<Product> products) {
    return products.map((p) => p.category).toSet().length;
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _buildPeriodButton('Daily', theme),
          _buildPeriodButton('Weekly', theme),
          _buildPeriodButton('Select Date', theme),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, ThemeData theme) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (period == 'Select Date') {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: theme.colorScheme,
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
                _selectedPeriod = period;
              });
            }
          } else {
            setState(() {
              _selectedPeriod = period;
              _selectedDate = null;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            period,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  List<Sale> _getFilteredSales(List<Sale> allSales) {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'Daily':
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        return allSales.where((sale) => 
          sale.date.isAfter(today) && sale.date.isBefore(tomorrow)
        ).toList();
        
      case 'Weekly':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
        final weekEnd = weekStartDay.add(const Duration(days: 7));
        return allSales.where((sale) => 
          sale.date.isAfter(weekStartDay) && sale.date.isBefore(weekEnd)
        ).toList();
        
      case 'Select Date':
        if (_selectedDate == null) return [];
        final selectedDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
        final nextDay = selectedDay.add(const Duration(days: 1));
        return allSales.where((sale) => 
          sale.date.isAfter(selectedDay) && sale.date.isBefore(nextDay)
        ).toList();
        
      default:
        return allSales;
    }
  }

  String _getPeriodDescription() {
    switch (_selectedPeriod) {
      case 'Daily':
        return 'Today\'s sales';
      case 'Weekly':
        return 'This week\'s sales';
      case 'Select Date':
        if (_selectedDate == null) return 'Select a date';
        return 'Sales for ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}';
      default:
        return '';
    }
  }

  String _getNoSalesMessage() {
    switch (_selectedPeriod) {
      case 'Daily':
        return 'No sales recorded for today';
      case 'Weekly':
        return 'No sales recorded for this week';
      case 'Select Date':
        if (_selectedDate == null) return 'Please select a date';
        return 'No sales recorded for ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}';
      default:
        return 'No sales data available';
    }
  }
  
  String _getStockDisplay(Product product) {
    if (product.isCigarette || product.category == 'cigarettes') {
      if (product.isOutOfStock) return '0 packs';
      return '${product.packStock} pack${product.packStock != 1 ? 's' : ''}';
    }
    return product.isOutOfStock ? '0' : '${product.stock}';
  }


}

class _StockResultsScreen extends StatelessWidget {
  final List<Product> products;
  final String title;

  const _StockResultsScreen({required this.products, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
        ),
        title: Text(
          title,
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📦', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'No items found',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: product.isOutOfStock
                        ? Colors.red.withOpacity(0.1)
                        : product.isLowStock
                            ? Colors.orange.withOpacity(0.1)
                            : theme.colorScheme.surface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: product.isOutOfStock
                          ? Colors.red.withOpacity(0.5)
                          : product.isLowStock
                              ? Colors.orange.withOpacity(0.5)
                              : theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
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
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.category,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _getStockDisplay(product),
                            style: TextStyle(
                              color: product.isOutOfStock
                                  ? Colors.red
                                  : product.isLowStock
                                      ? Colors.orange
                                      : theme.colorScheme.onSurface,
                              fontSize: 18,
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
                          if (product.isOutOfStock)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'OUT OF STOCK',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else if (product.isLowStock)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'LOW STOCK',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _getStockDisplay(Product product) {
    if (product.isCigarette || product.category == 'cigarettes') {
      if (product.isOutOfStock) return '0 packs';
      return '${product.packStock} pack${product.packStock != 1 ? 's' : ''}';
    }
    return product.isOutOfStock ? '0' : '${product.stock}';
  }
}