import 'package:flutter/material.dart';

import '../values/insets.dart';

/// A class that defines the dark theme for the application.
class DarkTheme {
  /// A convenience method for determining if the dark theme is enabled.
  static bool darkThemeEnabled(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  /// A border for text input form field widgets.
  static final OutlineInputBorder _border = OutlineInputBorder(
    borderSide: const BorderSide(
      color: Color(0xfdffffff),
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

  /// The [ThemeData] object for the dark theme.
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primaryColor: const Color(0xFFEDA200),
        primaryColorLight: const Color(0xff262626),
        primaryColorDark: const Color(0xfdffffff),
        scaffoldBackgroundColor: const Color(0xff262626),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 20,
          ),
        ),
        cardTheme: CardThemeData(
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
            color: Color(0xfdffffff),
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
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xff363636),
        ),
      );
}
