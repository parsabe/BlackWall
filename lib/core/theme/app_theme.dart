import 'package:flutter/material.dart';

class AppTheme {
  // Brand & Status Colors
  static const Color primary = Color(0xFF007AFF); // macOS / iOS System Blue
  static const Color primaryDark = Color(0xFF0A84FF);
  static const Color safeGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color criticalRed = Color(0xFFEF4444);

  // Light Mode Palette (White & Blue)
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Mode Palette
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceSecondary = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF1E293B);

  // Backwards-compatible aliases (dark defaults)
  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color surfaceLight = darkSurfaceSecondary;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color border = darkBorder;

  static const String macOsFontFamily = '.SF Pro Text';
  static const List<String> macOsFontFallback = [
    '.SF Pro Text',
    '.SF Pro Display',
    'SF Pro Text',
    'Inter',
    'Roboto',
    'sans-serif',
  ];

  static const List<String> monoFontFallback = [
    'SF Mono',
    'Menlo',
    'Monaco',
    'Consolas',
    'monospace',
  ];

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      primaryColor: primary,
      backgroundColor: lightBackground,
      surfaceColor: lightSurface,
      surfaceSecondary: lightSurfaceSecondary,
      textPrimaryColor: lightTextPrimary,
      textSecondaryColor: lightTextSecondary,
      borderColor: lightBorder,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      backgroundColor: darkBackground,
      surfaceColor: darkSurface,
      surfaceSecondary: darkSurfaceSecondary,
      textPrimaryColor: darkTextPrimary,
      textSecondaryColor: darkTextSecondary,
      borderColor: darkBorder,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color surfaceSecondary,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required Color borderColor,
  }) {
    final baseTextTheme =
        brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      dividerColor: borderColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: primaryColor,
        onSecondary: Colors.white,
        error: criticalRed,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimaryColor,
        surfaceContainerHighest: surfaceSecondary,
        onSurfaceVariant: textSecondaryColor,
        outline: borderColor,
      ),
      fontFamily: macOsFontFamily,
      fontFamilyFallback: macOsFontFallback,
      textTheme: baseTextTheme.apply(
        fontFamily: macOsFontFamily,
        fontFamilyFallback: macOsFontFallback,
        bodyColor: textPrimaryColor,
        displayColor: textPrimaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: borderColor, width: 1)),
        titleTextStyle: TextStyle(
          fontFamily: macOsFontFamily,
          fontFamilyFallback: macOsFontFallback,
          color: textPrimaryColor,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSecondary,
        hintStyle: TextStyle(color: textSecondaryColor, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: criticalRed),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}
