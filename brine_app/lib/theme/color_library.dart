import 'package:flutter/material.dart';

/// A library of custom colors used in the app. This [ThemeExtension] can be added to a [ThemeData] object to
/// provide custom colors using the `copyWith` method of [ThemeData].
@immutable
class ColorLibrary extends ThemeExtension<ColorLibrary> {
  /// Creates a [ColorLibrary] with the given colors.
  const ColorLibrary({
    required this.error,
  });

  /// The color used for error messages and other indicators of errors.
  final Color? error;

  @override
  ColorLibrary copyWith({Color? error}) {
    return ColorLibrary(
      error: error ?? this.error,
    );
  }

  @override
  ColorLibrary lerp(ColorLibrary? other, double t) {
    if (other is! ColorLibrary) {
      return this;
    }
    return ColorLibrary(
      error: Color.lerp(error, other.error, t),
    );
  }
}
