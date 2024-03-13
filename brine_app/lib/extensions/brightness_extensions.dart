import 'package:flutter/services.dart';

/// Contains extensions on the [Brightness] class.
extension BrightnessExtensions on Brightness {
  /// Returns the opposite [SystemUiOverlayStyle] compared to the current theme [Brightness]. In other words, if the
  /// current [Brightness] is [SystemUiOverlayStyle.light], this method returns [SystemUiOverlayStyle.dark] and vice
  /// versa.
  SystemUiOverlayStyle oppositeSystemOverlayStyle() {
    if (this == Brightness.light) {
      return SystemUiOverlayStyle.dark;
    } else {
      return SystemUiOverlayStyle.light;
    }
  }

  /// Syntactic sugar that returns a boolean which indicates if the current theme [Brightness] is dark. The function
  /// returns `true` if a dark theme mode is in use and `false` otherwise.
  bool get isDark => this == Brightness.dark;
}
