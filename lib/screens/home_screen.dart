import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import 'pos_screen.dart';
import 'inventory_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
    

  }
  
  Future<void> _loadStoreInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storeName = prefs.getString('store_name') ?? 'Tindahan Ko';
      _ownerName = prefs.getString('owner_name') ?? 'Store Owner';
    });
  }
  
  void _refreshStoreInfo() {
    _loadStoreInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.isDarkMode
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0F1724),
                        Color(0xFF111827),
                        Color(0xFF1F2937),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF6F7FB),
                        Color(0xFFE5E7EB),
                      ],
                    ),
            ),
            child: Column(
              children: [
                // Header
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Spacer(),
                            Column(
                              children: [
                                Text(
                                  'Tindahan Ko',
                                  style: GoogleFonts.getFont(
                                    'Imperial Script',
                                    fontSize: 28,
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Para sa mga Reyna ng Tindahan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'Inter',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  _storeName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Theme toggle button
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                ),
                              ),
                              child: IconButton(
                                onPressed: () => themeProvider.toggleTheme(),
                                icon: Icon(
                                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Content
                Expanded(
                  child: _currentIndex == 3 
                      ? SettingsScreen(onStoreInfoUpdated: _refreshStoreInfo)
                      : _screens[_currentIndex],
                ),
              ],
            ),
          ),
          
          // Bottom Navigation
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
              unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
              elevation: 0,
              selectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
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
      },
    );
  }
}