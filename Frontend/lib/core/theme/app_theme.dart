// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Futuristic Color Palette Colors
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color darkSlateSecondary = Color(0xFF1E293B);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color glowCyan = Color(0x3306B6D4);
  static const Color glowPurple = Color(0x338B5CF6);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightAccent = Color(0xFF0F766E); // Teal

  // Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightAccent,
        brightness: Brightness.light,
        primary: lightAccent,
        secondary: const Color(0xFF0D9488),
        background: lightBackground,
        surface: lightSurface,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 32, color: darkSlate),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: darkSlate),
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 20, color: darkSlate),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18, color: darkSlate),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: darkSlate),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        color: lightSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: Colors.grey.shade600),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }

  // Futuristic Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkSlate,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPurple,
        background: darkSlate,
        surface: darkSlateSecondary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Color(0xFFF1F5F9),
        onSurface: Color(0xFFF1F5F9),
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFE2E8F0)),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        color: darkSlateSecondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neonCyan, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonCyan,
          foregroundColor: darkSlate,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // Custom Glassmorphism Box Decoration
  static BoxDecoration glassDecoration({
    required BuildContext context,
    double opacity = 0.05,
    double blur = 10,
    double borderRadius = 16,
    Color? borderColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: (isDark ? Colors.white : Colors.black).withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? 
          (isDark ? Colors.white10 : Colors.black12),
        width: 1.5,
      ),
    );
  }
}
