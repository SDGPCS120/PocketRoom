import 'package:flutter/material.dart';
import 'package:pocketroom/src/core/theme/app_theme.dart';

void main() {
  final light = AppTheme.lightTheme;
  final dark = AppTheme.darkTheme;
  
  print('Light extension: ${light.extension<AppThemeExtension>()}');
  print('Dark extension: ${dark.extension<AppThemeExtension>()}');
  
  if (light.extension<AppThemeExtension>() == null) {
    print('ERROR: Light extension is NULL');
  } else {
    print('SUCCESS: Light extension is present');
  }

  if (dark.extension<AppThemeExtension>() == null) {
    print('ERROR: Dark extension is NULL');
  } else {
    print('SUCCESS: Dark extension is present');
  }
}
