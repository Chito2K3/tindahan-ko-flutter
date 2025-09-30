import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import 'pos_screen.dart';
import 'inventory_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String platform;
  
  const HomeScreen({super.key, required this.platform});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _storeName = '';
  String _ownerName = '';
  
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      const POSScreen(),
      const InventoryScreen(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];
    
    _loadStoreInfo();
    
    // Load sample data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().setPlatform(widget.platform);
      context.read<AppProvider>().loadSampleData();
    });
  }
  
  Future<void> _loadStoreInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storeName = prefs.getString('store_name') ?? 'Tindahan Ko';
      _ownerName = prefs.getString('owner_name') ?? 'Store Owner';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Column(
          children: [
            // Header
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground.withOpacity(0.3),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.cardBackground,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _storeName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Owned by $_ownerName',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Para sa mga Reyna ng Tahanan 👑',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground.withOpacity(0.3),
          border: Border(
            top: BorderSide(
              color: AppTheme.cardBackground,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.primaryPink,
          unselectedItemColor: AppTheme.textSecondary,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Text('💰', style: TextStyle(fontSize: 24)),
              label: 'Benta',
            ),
            BottomNavigationBarItem(
              icon: Text('📦', style: TextStyle(fontSize: 24)),
              label: 'Tindahan',
            ),
            BottomNavigationBarItem(
              icon: Text('📊', style: TextStyle(fontSize: 24)),
              label: 'Ulat',
            ),
            BottomNavigationBarItem(
              icon: Text('⚙️', style: TextStyle(fontSize: 24)),
              label: 'Ayos',
            ),
          ],
        ),
      ),
    );
  }
}