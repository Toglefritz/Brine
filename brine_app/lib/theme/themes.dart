import 'package:flutter/material.dart';

import 'color_library.dart';

/// Provides [ThemeData] for the application.
class BrineAppTheme {
  /// Default [TextTheme] used for both light and dark theme modes.
  static const TextTheme _defaultTextTheme = TextTheme(
    bodyLarge: TextStyle(
      fontSize: 18,
    ),
  );

  /// Default light theme data.
  static final ThemeData lightThemeData = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    primaryColor: const Color(0xFFEDA200),
    primaryColorLight: const Color(0xFFFFFFFF),
    primaryColorDark: const Color(0xFF212121),
    scaffoldBackgroundColor: const Color(0xFFEDA200),
    textTheme: _defaultTextTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFEDA200),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFFEDA200),
      selectionColor: Color(0xFFEDA200),
      selectionHandleColor: Color(0xFFEDA200),
    ),
  ).copyWith(
    extensions: <ThemeExtension<dynamic>>[
      const ColorLibrary(
        error: Color(0xFFA20000),
      ),
    ],
  );

  /// Default dark theme data.
  static final ThemeData darkThemeData = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    primaryColor: const Color(0xFFEDA200),
    primaryColorLight: const Color(0xFF212121),
    primaryColorDark: const Color(0xFFFFFFFF),
    scaffoldBackgroundColor: const Color(0xFF212121),
    textTheme: _defaultTextTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF212121),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFFEDA200),
      selectionColor: Color(0xFFEDA200),
      selectionHandleColor: Color(0xFFEDA200),
    ),
  ).copyWith(
    extensions: <ThemeExtension<dynamic>>[
      const ColorLibrary(
        error: Color(0xFFA20000),
      ),
    ],
  );
}
