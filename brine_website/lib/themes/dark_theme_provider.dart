import 'package:flutter/material.dart';
import 'dark_theme_preference.dart';

/// `DarkThemeProvider` is a [ChangeNotifier] that manages the state of the
/// application's theme mode. It is meant to be used with the [Provider] package
/// to propagate the theme state changes to the widgets that depend on it.
///
/// The class uses an instance of [DarkThemePreference] to access and modify
/// the persistent dark theme preference.
class DarkThemeProvider with ChangeNotifier {
  final DarkThemePreference darkThemePreference = DarkThemePreference();

  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }
}
