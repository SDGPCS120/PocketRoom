import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A dedicated class for holding your app's custom colors.
class AppColors {
  AppColors._();

  // Main branding colors
  static const Color primary = Color(0xFFE79742); // Updated to match product border/price
  static const Color secondary = Color(0xFFFFE5D3);
  static const Color background = Color(0xFFFFFFFF); // Updated to match card background
  
  // Text colors
  static const Color textPrimary = Color(0xFF1E293B); // Product card title
  static const Color textSecondary = Color(0xFF94A3B8); // Product card brand
  static const Color textRating = Color(0xFF444D5C); // Product card rating
  static const Color priceColor = Color(0xFFE79742);

  // Border colors
  static const Color cardBorder = Color(0xFFE79742);

  // Gradient for cards
  static const Gradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)], // Changed to solid white as per design
  );

  // Shadows
  static List<BoxShadow> productCardShadow = [
    BoxShadow(
      color: const Color(0xFFE79742).withOpacity(0.12),
      offset: const Offset(0, 10),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      offset: const Offset(0, 8),
      blurRadius: 10,
      spreadRadius: -6,
    ),
  ];
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
