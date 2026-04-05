import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dark_theme_preference.dart';

/// [DarkThemeProvider] is a [ChangeNotifier] that manages the state of the application's theme mode. It is meant to be
/// used with the [Provider] package to propagate the theme state changes to the widgets that depend on it.
///
/// The class uses an instance of [DarkThemePreference] to access and modify the persistent dark theme preference.
class DarkThemeProvider with ChangeNotifier {
  /// Constructor for [DarkThemeProvider]. It initializes the dark theme preference by calling the [DarkThemePreference]
  /// instance's `getTheme` method.
  final DarkThemePreference darkThemePreference = DarkThemePreference();

  /// Determines if a dark theme is enabled.
  bool _darkTheme = false;

  /// A getter for the dark theme preference. It retrieves the current dark theme setting from [DarkThemePreference].
  bool get darkTheme => _darkTheme;

  /// A method to initialize the dark theme preference. It retrieves the current dark theme setting from
  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value: value);
    notifyListeners();
  }
}
