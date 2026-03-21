import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Controls the app-wide theme mode. Defaults to light.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

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
  static const Color textSecondary = Color(0xFF757575);
  static const Color textRating = Color(0xFFFFA726);

  // Product card styling
  static const Color cardBorder = Color(0xFFE79742);
  static const Color priceColor = primary;
  static const List<BoxShadow> productCardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  // Gradient for cards
  static const Gradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE5D3), Color.fromRGBO(255, 212, 184, 1)],
  );
}

class AppSizes {
  AppSizes._();
  
  static const double pagePadding = 20.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 28.0;
  static const double buttonHeight = 52.0;
}

class AppTextStyles {
  AppTextStyles._();
  
  static const TextStyle appBarTitle = TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
  
  static const TextStyle profileName = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );
  
  static const TextStyle profileEmail = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
  
  static const TextStyle profileEdit = TextStyle(
    color: AppColors.secondary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}

class AppButtonStyles {
  AppButtonStyles._();
  
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
    ),
  );
  
  static final ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textPrimary,
    side: const BorderSide(color: AppColors.cardBorder),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
    ),
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
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    textTheme: GoogleFonts.fredokaTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: const Color(0xFF1A1A1A),
    ),
  );
}

