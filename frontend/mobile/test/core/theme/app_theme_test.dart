import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketroom/src/core/theme/app_theme.dart';

void main() {
  group('AppTheme ColorScheme & Extensions', () {
    test('lightTheme has correct ColorScheme and AppThemeExtension defaults', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, equals(AppColors.primary));
      expect(theme.colorScheme.surface, equals(AppColors.background));
      
      final extension = theme.extension<AppThemeExtension>();
      expect(extension, isNotNull);
      expect(extension!.cardBorder, equals(AppColors.cardBorder));
      expect(extension.priceColor, equals(AppColors.primary));
    });

    test('darkTheme has correct ColorScheme and AppThemeExtension overrides', () {
      final theme = AppTheme.darkTheme;
      
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.useMaterial3, isTrue);
      // Dark mode onSurface from AppColorSchemes.dark
      expect(theme.colorScheme.onSurface, equals(const Color(0xFFF5F5F5)));
      
      final extension = theme.extension<AppThemeExtension>();
      expect(extension, isNotNull);
      // Dark mode should have adjusted colors
      expect(extension!.cardBorder, equals(const Color(0xFF424242)));
      expect(extension.priceColor, equals(const Color(0xFFFFB385)));
    });

    test('AppColorSchemes light and dark are distinct', () {
      expect(AppColorSchemes.light.brightness, equals(Brightness.light));
      expect(AppColorSchemes.dark.brightness, equals(Brightness.dark));
      expect(AppColorSchemes.light.primary, isNot(equals(AppColorSchemes.dark.primary)));
    });
  });
}
