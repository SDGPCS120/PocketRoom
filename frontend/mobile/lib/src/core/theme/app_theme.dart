import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Make the constructor private so that this class cannot be instantiated.
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: const Color(0xFFFFF8F3),
    textTheme: GoogleFonts.fredokaTextTheme(),
  );

  // You can add a darkTheme here later if you want.
  // static final ThemeData darkTheme = ThemeData(...);
}
