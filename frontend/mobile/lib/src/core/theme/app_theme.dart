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

/// Custom theme extension for properties that don't fit into [ColorScheme].
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color? cardBorder;
  final Color? priceColor;
  final Gradient? cardGradient;
  final List<BoxShadow>? productCardShadow;
  final Color? textRating;

  const AppThemeExtension({
    required this.cardBorder,
    required this.priceColor,
    required this.cardGradient,
    required this.productCardShadow,
    required this.textRating,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? cardBorder,
    Color? priceColor,
    Gradient? cardGradient,
    List<BoxShadow>? productCardShadow,
    Color? textRating,
  }) {
    return AppThemeExtension(
      cardBorder: cardBorder ?? this.cardBorder,
      priceColor: priceColor ?? this.priceColor,
      cardGradient: cardGradient ?? this.cardGradient,
      productCardShadow: productCardShadow ?? this.productCardShadow,
      textRating: textRating ?? this.textRating,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t),
      priceColor: Color.lerp(priceColor, other.priceColor, t),
      cardGradient: Gradient.lerp(cardGradient, other.cardGradient, t),
      productCardShadow: BoxShadow.lerpList(productCardShadow, other.productCardShadow, t),
      textRating: Color.lerp(textRating, other.textRating, t),
    );
  }
}

class AppColorSchemes {
  AppColorSchemes._();

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: AppColors.primary,
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    error: Colors.redAccent,
    onError: Colors.white,
    outline: AppColors.cardBorder,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: Color(0xFF3D2C20),
    onSecondary: Color(0xFFFFB385),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFF5F5F5),
    onSurfaceVariant: Color(0xFFB0B0B0),
    error: Colors.redAccent,
    onError: Colors.white,
    outline: Color(0xFF424242),
  );
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
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: AppColorSchemes.light,
    scaffoldBackgroundColor: AppColorSchemes.light.surface,
    textTheme: GoogleFonts.fredokaTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    extensions: const [
      AppThemeExtension(
        cardBorder: AppColors.cardBorder,
        priceColor: AppColors.primary,
        cardGradient: AppColors.cardGradient,
        productCardShadow: AppColors.productCardShadow,
        textRating: AppColors.textRating,
      ),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: AppColorSchemes.dark,
    scaffoldBackgroundColor: AppColorSchemes.dark.surface,
    textTheme: GoogleFonts.fredokaTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    extensions: const [
      AppThemeExtension(
        cardBorder: Color(0xFF424242),
        priceColor: Color(0xFFFFB385),
        cardGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C2C2C), Color(0xFF131313)],
        ),
        productCardShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        textRating: Color(0xFFFFB74D),
      ),
    ],
  );
}

