import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFFF69B4);
  static const Color secondaryPink = Color(0xFFFFB6C1);
  static const Color lightPink = Color(0xFFFEEEF8);
  static const Color darkPink = Color(0xFFE91E63);
  
  static final ThemeData theme = ThemeData(
    primarySwatch: Colors.pink,
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
    colors: [primaryPink, Color(0xFFFF1493), Color(0xFFDC143C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}