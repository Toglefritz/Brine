import 'package:flutter/material.dart';

import '../values/insets.dart';

/// In this [ThemeData] object:
///
///   - Brightness.light specifies that the app is in light mode.
///   - Colors.teal is used for the primary color.
///   - Colors.grey[100] is used for the background color of the [Scaffold] and the bottom navigation bar. This is
///     a very light shade of gray that is commonly used in Material Design.
///   - The [appBarTheme] defines the style of the app bar. In this case, it has a white background color, no
///     elevation, and dark gray text with a font size of 18 and a weight of 500.
///   - The [bottomNavigationBarTheme] defines the style of the bottom navigation bar. It has a white background
///     color and teal for selected items and gray for unselected items.
///   - The [cardTheme] defines the style of cards. They have a white background color, a slight elevation, and
///     rounded corners with a radius of 8.
///   - the [textSelectionTheme] defines the colors of the cursor, handles, and text highlight when text elements
///     are selected.
///   - The [inputDecorationTheme] defines styling parameters for text input form field widgets.
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
          selectionColor: const Color(0xFFEDA200).withOpacity(0.2),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(
            color: Color(0xff212121),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: Insets.kInsetsLarge,
            vertical: Insets.kInsetsSmall,
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
