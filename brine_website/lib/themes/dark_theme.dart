import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
);
