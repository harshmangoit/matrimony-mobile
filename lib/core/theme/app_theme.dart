import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Color Palette
  static const Color primaryRoyalMaroon = Color(0xFF7A1C30);
  static const Color secondaryGold = Color(0xFFD4AF37);
  static const Color accentCrimson = Color(0xFF9E2A2B);
  static const Color softRoseBackground = Color(0xFFFFF8F9);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C1820);
  static const Color textSecondary = Color(0xFF6E5D65);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warningAmber = Color(0xFFE65100);
  static const Color borderLight = Color(0xFFEFE2E6);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryRoyalMaroon,
    scaffoldBackgroundColor: softRoseBackground,
    colorScheme: const ColorScheme.light(
      primary: primaryRoyalMaroon,
      secondary: secondaryGold,
      tertiary: accentCrimson,
      surface: cardSurface,
      error: accentCrimson,
    ),
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16, color: textPrimary
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14, color: textSecondary
      ),
    ),
    cardTheme: CardThemeData(
      color: cardSurface,
      elevation: 2,
      shadowColor: primaryRoyalMaroon.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderLight, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryRoyalMaroon, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentCrimson),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRoyalMaroon,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryRoyalMaroon,
        side: const BorderSide(color: primaryRoyalMaroon, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryRoyalMaroon,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white
      ),
    ),
  );
}
