import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Primary brand color
  static const Color primarySeedColor = Color(0xFF1E88E5);
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Surface colors
  static const Color lightScaffoldBg = Color(0xFFF8FAFC);
  static const Color darkScaffoldBg = Color(0xFF0B0F19);
  static const Color lightCardBg = Colors.white;
  static const Color darkCardBg = Color(0xFF161F30);
  static const Color lightBorderColor = Color(0xFFE2E8F0);
  static const Color darkBorderColor = Color(0xFF253248);

  // Light theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      primary: primarySeedColor,
      brightness: Brightness.light,
      surface: lightScaffoldBg,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: lightScaffoldBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: lightCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorderColor, width: 1.2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF64748B),
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: lightBorderColor, thickness: 1),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      primary: primarySeedColor,
      brightness: Brightness.dark,
      surface: darkScaffoldBg,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: darkScaffoldBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorderColor, width: 1.2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCardBg,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF94A3B8),
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCardBg,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: darkBorderColor, thickness: 1),
    );
  }
}
