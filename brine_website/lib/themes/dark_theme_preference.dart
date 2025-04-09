import 'package:shared_preferences/shared_preferences.dart';

/// `DarkThemePreference` is a helper class used for managing a user's dark mode
/// versus light mode preference across application sessions.
///
/// It uses the [SharedPreferences] library for persistent storage.
/// By storing this preference, the app can remember the user's preferred theme
/// and apply it automatically when the app is launched in future sessions.
/// This enhances the user experience by ensuring consistency with the user's
/// preferred visual comfort level.
class DarkThemePreference {
  /// A key used to store the user's dark mode versus light mode preference via
  /// [SharedPreferences].
  static const _themeModeKey = 'theme_mode';

  /// This method sets the user's theme preference (dark or light mode). It takes a `bool` value, where `true`
  /// indicates dark mode and `false` indicates light mode. The preference is stored in [SharedPreferences] with a
  /// key defined by [_themeModeKey].
  Future<void> setDarkTheme({required bool value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, value);
  }

  /// This method retrieves the user's theme preference from [SharedPreferences]. It returns a `Future<bool>`, which
  /// will be `true` if the user prefers dark mode and `false` if the user prefers light mode. If no preference has
  /// been set, it defaults to `false` (light mode), as this is typical default behavior for web apps.
  Future<bool> getTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_themeModeKey) ?? false;
  }
}
