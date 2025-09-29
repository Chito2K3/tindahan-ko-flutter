import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/landing_screen.dart';
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
        home: const LandingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}