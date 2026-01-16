import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. The Color Palette (Modern Dark)
  static const Color background = Color(0xFF121212); // Deep Matte Black
  static const Color surface = Color(0xFF1E1E1E);    // Slightly Lighter Card
  static const Color primary = Color(0xFF2962FF);    // Electric Blue Accent
  static const Color text = Color(0xFFFFFFFF);       // Pure White
  static const Color subText = Color(0xFFB3B3B3);    // Greyed Text

  // 2. The Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      
      // Text Theme (Clean & readable)
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: text,
        displayColor: text,
      ),

      // Card Theme (Rounded & Subtle)
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),

      // Input Field Theme (Minimalist)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: subText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
