import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketroom/src/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AppTheme ColorScheme & Extensions', () {
    test('AppColorSchemes light has correct defaults', () {
      const colorScheme = AppColorSchemes.light;
      
      expect(colorScheme.brightness, equals(Brightness.light));
      expect(colorScheme.primary, equals(AppColors.primary));
      expect(colorScheme.surface, equals(AppColors.background));
      expect(colorScheme.outline, equals(AppColors.cardBorder));
    });

    test('AppTheme.lightExtension has correct defaults', () {
      const extension = AppTheme.lightExtension;
      
      expect(extension.cardBorder, equals(AppColors.cardBorder));
      expect(extension.priceColor, equals(AppColors.primary));
    });

    test('AppColorSchemes dark has correct overrides', () {
      const colorScheme = AppColorSchemes.dark;
      
      expect(colorScheme.brightness, equals(Brightness.dark));
      expect(colorScheme.onSurface, equals(const Color(0xFFF5F5F5)));
      expect(colorScheme.outline, equals(AppColors.cardBorder));
    });

    test('AppTheme.darkExtension has correct overrides', () {
      const extension = AppTheme.darkExtension;
      
      expect(extension.cardBorder, equals(AppColors.cardBorder));
      expect(extension.priceColor, equals(const Color(0xFFFFB385)));
    });

    test('AppColorSchemes light and dark are distinct', () {
      expect(AppColorSchemes.light.brightness, equals(Brightness.light));
      expect(AppColorSchemes.dark.brightness, equals(Brightness.dark));
      expect(AppColorSchemes.light.surface, isNot(equals(AppColorSchemes.dark.surface)));
    });
  });
}
