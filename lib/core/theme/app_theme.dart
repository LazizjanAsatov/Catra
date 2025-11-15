import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A73E8),
        brightness: Brightness.light,
      ),
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF1A73E8),
        secondary: const Color(0xFF0F9BEB),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFFE3F2FD),
        labelStyle: const TextStyle(color: Color(0xFF0F4C81)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0B3A67),
        brightness: Brightness.dark,
      ),
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF64B5F6),
        secondary: const Color(0xFF90CAF9),
        surface: const Color(0xFF152238),
      ),
      scaffoldBackgroundColor: const Color(0xFF0B1324),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: const Color(0xFF1F2B3F),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFF1F2B3F),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
