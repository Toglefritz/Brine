import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

/// `Screen` is a utility class that provides easy access to the current screen's dimensions,
/// both in pixels and inches, as well as determining its orientation.
///
/// This class includes static methods for determining the screen size in both
/// pixels and inches. It also includes methods to determine if the screen is in
/// landscape orientation.
///
/// The PPI (Pixels Per Inch) value used for conversion to inches is assumed as
/// 150 for Android and iOS devices, and 96 for other platforms.
///
/// Note: It is important to ensure that MediaQuery data is available
/// in the context used with these methods.
class Screen {
  /// Private getter `_ppi` provides the assumed Pixels Per Inch based on the platform.
  static double get _ppi => (Platform.isAndroid || Platform.isIOS) ? 150 : 96;

  /// Returns a boolean indicating whether the screen is in landscape orientation.
  static bool isLandscape(BuildContext c) => MediaQuery.of(c).orientation == Orientation.landscape;

  // PIXELS

  /// Returns the total screen size in pixels as a `Size`.
  static Size size(BuildContext c) => MediaQuery.of(c).size;

  /// Returns the screen width in pixels.
  static double width(BuildContext c) => size(c).width;

  /// Returns the screen height in pixels.
  static double height(BuildContext c) => size(c).height;

  /// Returns the diagonal of the screen in pixels.
  static double diagonal(BuildContext c) {
    Size s = size(c);
    return sqrt((s.width * s.width) + (s.height * s.height));
  }

  // INCHES

  /// Returns the total screen size in inches as a `Size`.
  static Size inches(BuildContext c) {
    Size pxSize = size(c);
    return Size(pxSize.width / _ppi, pxSize.height / _ppi);
  }

  /// Returns the screen width in inches.
  static double widthInches(BuildContext c) => inches(c).width;

  /// Returns the screen height in inches.
  static double heightInches(BuildContext c) => inches(c).height;

  /// Returns the diagonal of the screen in inches.
  static double diagonalInches(BuildContext c) => diagonal(c) / _ppi;
}
