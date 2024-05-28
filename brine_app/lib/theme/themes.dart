import 'package:flutter/material.dart';

import 'color_library.dart';

/// Default [TextTheme] used for both light and dark theme modes.
const TextTheme defaultTextTheme = TextTheme(
  bodyLarge: TextStyle(
    fontSize: 18,
  ),
);

/// Default light theme data.
final ThemeData lightThemeData = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  primaryColor: const Color(0xFFEDA200),
  primaryColorLight: const Color(0xFFFFFFFF),
  primaryColorDark: const Color(0xFF212121),
  scaffoldBackgroundColor: const Color(0xFFEDA200),
  textTheme: defaultTextTheme,
).copyWith(
  extensions: <ThemeExtension<dynamic>>[
    const ColorLibrary(
      error: Color(0xFFA20000),
    ),
  ],
);

/// Default dark theme data.
final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  primaryColor: const Color(0xFFEDA200),
  primaryColorLight: const Color(0xFF212121),
  primaryColorDark: const Color(0xFFFFFFFF),
  scaffoldBackgroundColor: const Color(0xFF212121),
  textTheme: defaultTextTheme,
).copyWith(
  extensions: <ThemeExtension<dynamic>>[
    const ColorLibrary(
      error: Color(0xFFA20000),
    ),
  ],
);
