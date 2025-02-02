import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: const Color.fromRGBO(74, 111, 165, 1),      // Subtle blue
      onPrimary: const Color.fromRGBO(255, 255, 255, 1),
      primaryContainer: const Color.fromRGBO(227, 234, 244, 1),
      onPrimaryContainer: const Color.fromRGBO(26, 52, 79, 1),

      secondary: const Color.fromRGBO(147, 122, 165, 1),    // Soft purple
      onSecondary: const Color.fromRGBO(255, 255, 255, 1),
      secondaryContainer: const Color.fromRGBO(244, 227, 244, 1),
      onSecondaryContainer: const Color.fromRGBO(63, 42, 79, 1),

      surface: const Color.fromRGBO(255, 255, 255, 1),
      onSurface: const Color.fromRGBO(28, 27, 31, 1),
      surfaceVariant: const Color.fromRGBO(245, 245, 245, 1),
      onSurfaceVariant: const Color.fromRGBO(69, 70, 79, 1),

      background: const Color.fromRGBO(250, 250, 250, 1),
      onBackground: const Color.fromRGBO(28, 27, 31, 1),

      error: const Color.fromRGBO(179, 38, 30, 1),
      shadow: const Color.fromRGBO(0, 0, 0, 0.1),
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

    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: const Color.fromRGBO(28, 27, 31, 1),
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
        borderSide: BorderSide(color: const Color.fromRGBO(74, 111, 165, 1)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

// Dark theme can be added here following similar pattern
}