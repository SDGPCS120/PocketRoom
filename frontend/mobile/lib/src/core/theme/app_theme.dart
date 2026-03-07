import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A dedicated class for holding your app's custom colors.
class AppColors {
  // This class is not meant to be instantiated.
  AppColors._();

  // Main branding colors
  static const Color primary = Color(0xFFFF8A3D);
  static const Color secondary = Color(0xFFFFE5D3);
  static const Color background = Color(0xFFFFF8F3);

  // Text colors
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(
    0xFF757575,
  ); // A slightly lighter grey

  // Gradient for cards
  static const Gradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE5D3), Color.fromRGBO(255, 212, 184, 1)],
  );
}

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    // Use the new AppColors class for consistency.
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.fredokaTextTheme(),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.background,
    ),
    // You could also define a text theme here to use AppColors.textPrimary
    // as the default text color throughout the app.
  );
}
