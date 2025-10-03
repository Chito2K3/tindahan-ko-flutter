import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }
  
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
  
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}

class AppColors {
  // Light mode colors
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF6F7FB);
  static const lightPrimary = Color(0xFFFF477E);
  static const lightText = Color(0xFF111827);
  static const lightMuted = Color(0xFF6B7280);
  
  // Dark mode colors
  static const darkBackground = Color(0xFF0F1724);
  static const darkSurface = Color(0xFF111827);
  static const darkPrimary = Color(0xFFFF8AA8);
  static const darkText = Color(0xFFE6EEF8);
  static const darkMuted = Color(0xFF9CA3AF);
  
  // Brand accent (coral)
  static const accent = Color(0xFFFF6B6B);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.lightPrimary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.accent,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightText,
      onBackground: AppColors.lightText,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: AppColors.lightText,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: AppColors.lightText,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        color: AppColors.lightText,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        color: AppColors.lightText,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        minimumSize: const Size(0, 44),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.lightPrimary,
      unselectedItemColor: AppColors.lightMuted,
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.darkPrimary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.accent,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkText,
      onBackground: AppColors.darkText,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        minimumSize: const Size(0, 44),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface.withOpacity(0.9),
      selectedItemColor: AppColors.darkPrimary,
      unselectedItemColor: AppColors.darkMuted,
    ),
  );
}