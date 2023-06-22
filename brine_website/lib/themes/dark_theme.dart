import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../values/insets.dart';

/// In this [ThemeData] object:
///
///   - Brightness.dark specifies that the app is in dark mode.
///   - Colors.teal is used for the primary color.
///   - Colors.grey[900] is used for the background color of the [Scaffold] and the bottom navigation bar. This is a
///     very dark shade of gray that is commonly used in Material Design.
///   - The [appBarTheme] defines the style of the app bar. In this case, it has a dark gray background color, no
///     elevation, and white text with a font size of 18 and a weight of 500.
///   - The [cardTheme] defines the style of cards. They have a dark gray background color, a slight elevation,
///     and rounded corners with a radius of 8.
///     rounded corners with a radius of 8.
///   - the [textSelectionTheme] defines the colors of the cursor, handles, and text highlight when text elements
///     are selected.
///   - The [inputDecorationTheme] defines styling parameters for text input form field widgets.

OutlineInputBorder border = OutlineInputBorder(
  borderSide: const BorderSide(
    color: Color(0xfdffffff),
    width: 2.0,
  ),
  borderRadius: BorderRadius.circular(50),
);

OutlineInputBorder errorBorder = OutlineInputBorder(
  borderSide: BorderSide(
    color: Colors.red[900]!,
    width: 2.0,
  ),
  borderRadius: BorderRadius.circular(50),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  primaryColor: Colors.amber,
  primaryColorLight: const Color(0xff262626),
  primaryColorDark: const Color(0xfdffffff),
  scaffoldBackgroundColor: const Color(0xff262626),
  fontFamily: GoogleFonts.mavenPro().fontFamily,
  appBarTheme: AppBarTheme(
    color: Colors.grey[900],
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
    cursorColor: Colors.amber,
    selectionHandleColor: Colors.amber,
    selectionColor: Colors.amber.withOpacity(0.2),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(
      color: Color(0xfdffffff),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: Insets.kInsetsLarge,
      vertical: Insets.kInsetsSmall,
    ),
    border: border,
    enabledBorder: border,
    focusedBorder: border,
    errorBorder: errorBorder,
    errorStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    filled: false,
  ),
  dialogTheme: const DialogTheme(
    backgroundColor: Color(0xff363636),
  ),
);
