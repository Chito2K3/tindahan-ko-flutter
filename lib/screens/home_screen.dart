import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:provider/provider.dart';
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
    
    // Load sample data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().setPlatform(widget.platform);
      context.read<AppProvider>().loadSampleData();
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
                  color: Colors.white.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Tindahan Ko',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Para sa mga Reyna ng Tahanan 👑',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    8.heightBox,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.platform.toUpperCase()} Version',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
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
          color: Colors.white.withOpacity(0.1),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.2),
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
          unselectedItemColor: Colors.white70,
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