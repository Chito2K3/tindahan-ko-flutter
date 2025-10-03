import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/store_setup_screen.dart';
import 'screens/home_screen.dart';
import 'providers/app_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const TindahanKoApp());
}

class TindahanKoApp extends StatelessWidget {
  const TindahanKoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Tindahan Ko',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const InitialScreen(),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize database and load products
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.loadProducts();
    
    // Check setup status
    final prefs = await SharedPreferences.getInstance();
    final isSetupComplete = prefs.getBool('is_setup_complete') ?? false;
    
    if (mounted) {
      if (isSetupComplete) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const StoreSetupScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}