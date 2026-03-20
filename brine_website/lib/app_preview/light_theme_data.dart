import 'package:flutter/material.dart';

import 'color_library.dart';

/// [ThemeData] used for the Brine app preview.
ThemeData lightThemeData = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  primaryColor: const Color(0xFFEDA200),
  primaryColorLight: Colors.white,
  primaryColorDark: const Color(0xFF212121),
  scaffoldBackgroundColor: const Color(0xFFEDA200),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontSize: 18,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFEDA200),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFFEDA200),
    selectionColor: Color(0xFFEDA200),
    selectionHandleColor: Color(0xFFEDA200),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    hoverColor: Color(0xFF212121),
    focusColor: Color(0xFF212121),
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xFF212121),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xFF212121),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xFF212121),
      ),
    ),
    labelStyle: TextStyle(
      color: Color(0xFF212121),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all<Color>(
        const Color(0xFF212121),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 14,
          color: Color(0xFF212121),
        ),
      ),
    ),
  ),
).copyWith(
  extensions: <ThemeExtension<dynamic>>[
    const ColorLibrary(
      error: Color(0xFFA20000),
    ),
  ],
);
