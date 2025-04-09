import 'package:flutter/material.dart';

import '../values/insets.dart';

/// A class that defines the light theme for the application.
class LightTheme {
  /// A border for text input form field widgets.
  static final OutlineInputBorder _border = OutlineInputBorder(
    borderSide: const BorderSide(
      color: Color(0xff212121),
      width: 2.0,
    ),
    borderRadius: BorderRadius.circular(50),
  );

  /// A border for text input form field widgets when an error is present.
  static final OutlineInputBorder _errorBorder = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.red[900]!,
      width: 2.0,
    ),
    borderRadius: BorderRadius.circular(50),
  );

  /// The [ThemeData] object for the light theme.
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        primaryColor: const Color(0xFFEDA200),
        scaffoldBackgroundColor: const Color(0xFFF3BF50),
        primaryColorDark: const Color(0xff212121),
        primaryColorLight: Colors.grey[200],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 20,
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color(0xFFEDA200),
          selectionHandleColor: const Color(0xFFEDA200),
          selectionColor: const Color(0xFFEDA200).withValues(alpha: 0.2),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(
            color: Color(0xff212121),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: Insets.large,
            vertical: Insets.small,
          ),
          border: _border,
          enabledBorder: _border,
          focusedBorder: _border,
          errorBorder: _errorBorder,
          errorStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      );
}
