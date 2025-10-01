import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/store_setup_screen.dart';
import 'screens/home_screen.dart';
import 'providers/app_provider.dart';
import 'utils/theme.dart';

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
      ],
      child: MaterialApp(
        title: 'Tindahan Ko',
        theme: AppTheme.theme,
        home: const InitialScreen(),
        debugShowCheckedModeBanner: false,
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