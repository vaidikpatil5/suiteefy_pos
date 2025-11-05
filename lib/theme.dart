import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color pearlIvory = Color(0xFFFAF6F3);
  static const Color roseDust = Color(0xFFD8A7A0);
  static const Color lilacTaupe = Color(0xFFB8A1D9);
  static const Color satinGold = Color(0xFFC9A96A);
  static const Color deepCocoa = Color(0xFF4B3A32);
  static const Color bodyText = Color(0xFF5C4C45);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: pearlIvory,
      primaryColor: roseDust,
      colorScheme: ColorScheme.light(
        primary: roseDust,
        secondary: lilacTaupe,
        tertiary: satinGold,
        surface : pearlIvory,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: pearlIvory,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: deepCocoa,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: satinGold),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineSmall: GoogleFonts.poppins(
          color: deepCocoa,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: bodyText,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.poppins(
          color: bodyText,
          fontSize: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: roseDust,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lilacTaupe,
          side: const BorderSide(color: lilacTaupe),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

cardTheme: CardThemeData(
  color: Colors.white,
  elevation: 2,
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(color: Color(0xFFC9A96A), width: 0.3),
  ),
),

    );
  }
}

