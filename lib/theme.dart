import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Brand Colors ---
  static const Color background = Color.fromARGB(
    255,
    224,
    204,
    169,
  ); // warm beige
  static const Color darkBrown = Color.fromARGB(250, 51, 33, 22); // deep brown
  static const Color lightBrown = Color.fromARGB(
    250,
    220,
    200,
    175,
  ); // soft tan
  static const Color accentGold = Color.fromARGB(
    255,
    201,
    169,
    106,
  ); // satin gold tone
  static const Color roseDust = Color.fromARGB(255, 255, 182, 193); // rose dust
  static const Color satinGold = accentGold; // alias for accentGold
  static const Color deepCocoa = darkBrown; // alias for darkBrown

  // --- Main Theme ---
  static ThemeData get lightTheme {
    final base = ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: darkBrown,
      colorScheme: base.colorScheme.copyWith(
        primary: darkBrown,
        secondary: accentGold,
        surface: lightBrown,
        background: background,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: darkBrown,
        ),
        displayMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: darkBrown,
        ),
        displaySmall: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: darkBrown,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          color: darkBrown,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          color: darkBrown,
        ),
        labelLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: darkBrown,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightBrown,
          foregroundColor: darkBrown,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBrown,
        foregroundColor: darkBrown,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: darkBrown,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkBrown,
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightBrown.withOpacity(0.4),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: accentGold, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: lightBrown, width: 1.0),
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: GoogleFonts.poppins(
          color: darkBrown,
          fontWeight: FontWeight.w400,
        ),
      ),
      iconTheme: const IconThemeData(color: darkBrown, size: 22),
    );
  }
}
