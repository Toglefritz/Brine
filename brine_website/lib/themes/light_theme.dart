import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  primaryColor: Colors.amber,
  scaffoldBackgroundColor: Colors.grey[200],
  primaryColorDark: const Color(0xff212121),
  primaryColorLight: Colors.grey[200],
  fontFamily: GoogleFonts.mavenPro().fontFamily,
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
);
