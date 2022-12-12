import 'package:flutter/material.dart';

/// The default light [ColorScheme] if the app is unable to build a dynamic Material color scheme.
final ColorScheme defaultLightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFFEDA200),
);

/// The default dark [ColorScheme] if the app is unable to build a dynamic Material color scheme.
final ColorScheme defaultDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFFEDA200),
  brightness: Brightness.dark,
);

/// Default [TextTheme] used for both light and dark theme modes.
const TextTheme defaultTextTheme = TextTheme(
  bodyText1: TextStyle(
    fontSize: 18,
  ),
);

/// Default light theme data.
final ThemeData lightThemeData = ThemeData(
  colorScheme: defaultLightColorScheme,
  useMaterial3: true,
  textTheme: defaultTextTheme,
);

/// Default dark theme data.
final ThemeData darkThemeData = ThemeData(
  colorScheme: defaultDarkColorScheme,
  useMaterial3: true,
  textTheme: defaultTextTheme,
);
