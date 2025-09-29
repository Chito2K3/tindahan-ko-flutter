import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFA2A2D0); // Blue Belle
  static const Color secondaryPink = Color(0xFFB8B8E0);
  static const Color lightPink = Color(0xFFE8E8F5);
  static const Color darkPink = Color(0xFF7A7AB8);
  
  static final ThemeData theme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: primaryPink,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
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
  
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryPink, Color(0xFF9090C8), Color(0xFF6B6BB0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}