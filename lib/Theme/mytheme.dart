import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color.fromRGBO(74, 111, 165, 1),      // Subtle blue
      onPrimary: Color.fromRGBO(255, 255, 255, 1),
      primaryContainer: Color.fromRGBO(227, 234, 244, 1),
      onPrimaryContainer: Color.fromRGBO(26, 52, 79, 1),

      secondary: Color.fromRGBO(147, 122, 165, 1),    // Soft purple
      onSecondary: Color.fromRGBO(255, 255, 255, 1),
      secondaryContainer: Color.fromRGBO(244, 227, 244, 1),
      onSecondaryContainer: Color.fromRGBO(63, 42, 79, 1),

      surface: Color.fromRGBO(255, 255, 255, 1),
      onSurface: Color.fromRGBO(28, 27, 31, 1),
      surfaceContainerHighest: Color.fromRGBO(245, 245, 245, 1),
      onSurfaceVariant: Color.fromRGBO(69, 70, 79, 1),

      background: Color.fromRGBO(250, 250, 250, 1),
      onBackground: Color.fromRGBO(28, 27, 31, 1),

      error: Color.fromRGBO(179, 38, 30, 1),
      shadow: Color.fromRGBO(0, 0, 0, 0.1),
    ),

    // Typography
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.lora(
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.lora(
        fontSize: 14,
        height: 1.5,
      ),
    ),

    // Component Themes
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color.fromRGBO(28, 27, 31, 1),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color.fromRGBO(245, 245, 245, 1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color.fromRGBO(74, 111, 165, 1)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

// Dark theme can be added here following similar pattern
}