import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. The Auvid Color Palette (Purple Haze)
  static const Color background = Color(0xFF121212); // Deep Matte Black
  static const Color surface = Color(0xFF1E1E1E);    // Slightly Lighter Card
  
  // The New Hero Colors
  static const Color primary = Color(0xFF7C4DFF);    // Vibrant Purple (Logo Match)
  static const Color primaryDark = Color(0xFF651FFF); // Darker Purple for borders/shadows
  static const Color accent = Color(0xFFB388FF);      // Soft Lavender for highlights
  
  static const Color text = Color(0xFFFFFFFF);       // Pure White
  static const Color subText = Color(0xFFB3B3B3);    // Greyed Text

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF); // White
  static const Color lightSurface = Color(0xFFF5F5F5);    // Light Grey
  static const Color lightText = Color(0xFF000000);       // Black
  static const Color lightSubText = Color(0xFF666666);    // Dark Grey

  // 2. The Signature Gradient (Use this on Buttons & Headers)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF7C4DFF), // Lighter Purple
      Color(0xFF651FFF), // Deep Purple
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 3. Dark Theme
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
        hintStyle: const TextStyle(color: subText),
        // Default Border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        // Focused Border (The Purple Glow)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      
      // Standard Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: primary,
      
      // Text Theme
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: lightText,
        displayColor: lightText,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
      ),

      // Input Field Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        hintStyle: TextStyle(color: lightSubText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      
      // Standard Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}
