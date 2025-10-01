import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFE91E63); // Bright pink for buttons
  static const Color darkBackground = Color(0xFF2D1B2E); // Dark purple background
  static const Color cardBackground = Color(0xFF4A2C4A); // Purple card background
  static const Color inputBackground = Color(0xFF5D3A5D); // Burgundy input fields
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  
  static final ThemeData theme = ThemeData(
    primarySwatch: Colors.pink,
    primaryColor: primaryPink,
    scaffoldBackgroundColor: darkBackground,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: textPrimary, 
      displayColor: textPrimary,
      fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      foregroundColor: textPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
  );
  
  // Helper method to ensure peso sign displays correctly
  static String formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }
  
  static const Gradient primaryGradient = LinearGradient(
    colors: [darkBackground, cardBackground],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}