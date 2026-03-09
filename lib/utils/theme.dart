import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryDark = Color(0xFF0D1B2A);
  static const Color secondaryDark = Color(0xFF1A2E45);
  static const Color cardDark = Color(0xFF1E3A5F);
  static const Color accentGold = Color(0xFFF5A623);
  static const Color accentGoldLight = Color(0xFFFFD166);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0C4DE);
  static const Color textMuted = Color(0xFF7A9BBF);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53E3E);
  static const Color divider = Color(0xFF2A4A6B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        secondary: accentGoldLight,
        surface: secondaryDark,
        error: error,
        onPrimary: primaryDark,
        onSecondary: primaryDark,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondaryDark,
        selectedItemColor: accentGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textSecondary),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentGold,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: secondaryDark,
        selectedColor: accentGold,
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
        selectedShadowColor: Colors.transparent,
        shadowColor: Colors.transparent,
        side: const BorderSide(color: divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 28),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 22),
        headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
        titleSmall: TextStyle(color: textSecondary, fontSize: 13),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: textMuted, fontSize: 12),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

class AppConstants {
  static const List<String> categories = [
    'All',
    'CafÃ©',
    'Restaurant',
    'Hospital',
    'Police Station',
    'Library',
    'Park',
    'Tourist Attraction',
    'Pharmacy',
    'Bank',
    'Supermarket',
    'Hotel',
    'Gym',
    'School',
    'Utility Office',
  ];

  static const Map<String, String> categoryIcons = {
    'CafÃ©': 'â˜•',
    'Restaurant': 'ðŸ½ï¸',
    'Hospital': 'ðŸ¥',
    'Police Station': 'ðŸš”',
    'Library': 'ðŸ“š',
    'Park': 'ðŸŒ³',
    'Tourist Attraction': 'ðŸ›ï¸',
    'Pharmacy': 'ðŸ’Š',
    'Bank': 'ðŸ¦',
    'Supermarket': 'ðŸ›’',
    'Hotel': 'ðŸ¨',
    'Gym': 'ðŸ’ª',
    'School': 'ðŸŽ“',
    'Utility Office': 'ðŸ¢',
  };
}
