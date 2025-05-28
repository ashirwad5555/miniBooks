import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define gradient colors as constants
  static const Color gradientStart = Color(0xFFff9a9e);
  static const Color gradientEnd = Color(0xFFfad0c4);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      // Primary colors based on pink gradient
      primary: Color(0xFFff9a9e), // Main pink
      onPrimary: Color.fromARGB(255, 0, 0, 0), // White text on pink
      primaryContainer: Color(0xFFfce4ec), // Light pink container
      onPrimaryContainer: Color(0xFF4a1c1c), // Dark red text

      // Secondary colors - complementary warm tones
      secondary: Color(0xFFffd7d1), // Soft peach
      onSecondary: Color(0xFF442922), // Dark brown text
      secondaryContainer: Color(0xFFffeee9), // Very light peach
      onSecondaryContainer: Color(0xFF2d1b17), // Dark brown

      // Tertiary colors - accent colors
      tertiary: Color(0xFFffab91), // Coral orange
      onTertiary: Color(0xFF442920), // Dark text
      tertiaryContainer: Color(0xFFffeee5), // Light coral
      onTertiaryContainer: Color(0xFF2d1711), // Dark text

      // Surface colors
      surface: Color(0xFFffffff), // Pure white
      onSurface: Color(0xFF1f1f1f), // Dark gray text
      surfaceContainerHighest: Color(0xFFf8f8f8), // Very light gray
      surfaceContainer: Color(0xFFf5f5f5), // Light gray
      onSurfaceVariant: Color(0xFF5f5f5f), // Medium gray text

      // Background colors
      background: Color(0xFFfefbff), // Off-white background
      onBackground: Color(0xFF1f1f1f), // Dark text

      // Outline and border colors
      outline: Color(0xFFe0bfb7), // Soft pink outline
      outlineVariant: Color(0xFFf2e7e4), // Very light pink

      // Error colors
      error: Color(0xFFd32f2f), // Standard red
      onError: Color(0xFFffffff), // White text on error
      errorContainer: Color(0xFFffebee), // Light red container
      onErrorContainer: Color(0xFF5f2120), // Dark red text

      // Shadow and other colors
      shadow: Color(0x1A000000), // Light shadow
      inverseSurface: Color(0xFF2f2f2f), // Dark surface for inverse
      onInverseSurface: Color(0xFFf0f0f0), // Light text on dark
    ),

    // Typography with elegant fonts
    textTheme: TextTheme(
      // Display styles
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: const Color(0xFF1f1f1f),
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: const Color(0xFF1f1f1f),
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: const Color(0xFF1f1f1f),
      ),

      // Headline styles
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: const Color(0xFF1f1f1f),
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: const Color(0xFF1f1f1f),
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: const Color(0xFF1f1f1f),
      ),

      // Title styles
      titleLarge: GoogleFonts.lora(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: const Color(0xFF1f1f1f),
      ),
      titleMedium: GoogleFonts.lora(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: const Color(0xFF1f1f1f),
      ),
      titleSmall: GoogleFonts.lora(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: const Color(0xFF1f1f1f),
      ),

      // Body styles
      bodyLarge: GoogleFonts.lora(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
        color: const Color(0xFF1f1f1f),
      ),
      bodyMedium: GoogleFonts.lora(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
        color: const Color(0xFF1f1f1f),
      ),
      bodySmall: GoogleFonts.lora(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.4,
        color: const Color(0xFF5f5f5f),
      ),

      // Label styles
      labelLarge: GoogleFonts.lora(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: const Color(0xFF1f1f1f),
      ),
      labelMedium: GoogleFonts.lora(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: const Color(0xFF1f1f1f),
      ),
      labelSmall: GoogleFonts.lora(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: const Color(0xFF5f5f5f),
      ),
    ),

    // AppBar theme with gradient support
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black, // Changed to black
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black, // Changed to black
      ),
    ),

    // Card theme
    cardTheme: CardTheme(
      elevation: 4,
      shadowColor: const Color(0x1A000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: const Color(0xFFffffff),
      surfaceTintColor: const Color(0xFFfce4ec),
    ),

    // Elevated Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFff9a9e),
        foregroundColor: const Color(0xFFffffff),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: const Color(0x40ff9a9e),
      ),
    ),

    // Text Button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFff9a9e),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Outlined Button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFff9a9e),
        side: const BorderSide(color: Color(0xFFff9a9e), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Input Decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFffeee9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFe0bfb7), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFff9a9e), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFd32f2f), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFd32f2f), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF9e9e9e)),
    ),

    // Floating Action Button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFff9a9e),
      foregroundColor: Color(0xFFffffff),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Bottom Navigation Bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFffffff),
      selectedItemColor: Color(0xFFff9a9e),
      unselectedItemColor: Color(0xFF9e9e9e),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFffeee9),
      selectedColor: const Color(0xFFff9a9e),
      labelStyle: const TextStyle(color: Color(0xFF442922)),
      secondaryLabelStyle: const TextStyle(color: Color(0xFFffffff)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 2,
    ),

    // Divider theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFFe0bfb7),
      thickness: 1,
      space: 1,
    ),

    // Dialog theme
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFFffffff),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
    ),

    // Bottom Sheet theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFFffffff),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 8,
    ),
  );

  // Dark theme with similar pink-based color scheme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      // Primary colors for dark theme
      primary: Color(0xFFffb3ba), // Lighter pink for dark
      onPrimary: Color(0xFF2d1518), // Dark text on pink
      primaryContainer: Color(0xFF5a2d33), // Dark pink container
      onPrimaryContainer: Color(0xFFfce4ec), // Light text

      // Secondary colors
      secondary: Color(0xFFe6b8b0), // Muted peach
      onSecondary: Color(0xFF2d1b17), // Dark text
      secondaryContainer: Color(0xFF442922), // Dark container
      onSecondaryContainer: Color(0xFFffeee9), // Light text

      // Surface colors for dark theme
      surface: Color(0xFF1a1a1a), // Dark surface
      onSurface: Color(0xFFe8e8e8), // Light text
      surfaceContainerHighest: Color(0xFF2a2a2a), // Elevated surface

      // Background
      background: Color(0xFF121212), // Dark background
      onBackground: Color(0xFFe8e8e8), // Light text

      // Error colors
      error: Color(0xFFffb4ab), // Light red for dark
      onError: Color(0xFF690005), // Dark red text
    ),
    // Add similar component themes adapted for dark mode...
  );

  // Helper method to create gradient decoration
  static BoxDecoration getGradientDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  // Helper method to create gradient with custom colors
  static BoxDecoration getCustomGradientDecoration({
    required Color startColor,
    required Color endColor,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [startColor, endColor],
        begin: begin,
        end: end,
      ),
    );
  }
}
