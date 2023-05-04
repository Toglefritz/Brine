import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

/// Provides information about the screen size.
class ScreenInfo {
  /// The pixels per inch of the host device's display.
  static double get _ppi => (Platform.isAndroid || Platform.isIOS) ? 150 : 96;

  /// Determines if the host device's display is in landscape orientation.
  static bool isLandscape(BuildContext c) => MediaQuery.of(c).orientation == Orientation.landscape;

  // Pixels
  /// The [Size] of the host device's display in pixels.
  static Size size(BuildContext c) => MediaQuery.of(c).size;

  /// The width of the host device's display in pixels.
  static double width(BuildContext c) => size(c).width;

  /// The height of the host device's display in pixels.
  static double height(BuildContext c) => size(c).height;

  /// The diagonal measurement of the host device's display in pixels.
  static double diagonal(BuildContext c) {
    Size s = size(c);
    return sqrt((s.width * s.width) + (s.height * s.height));
  }

  // Inches
  /// The [Size] of the host device's display in inches.
  static Size inches(BuildContext c) {
    Size pxSize = size(c);
    return Size(pxSize.width / _ppi, pxSize.height / _ppi);
  }

  /// The width of the host device's display in inches.
  static double widthInches(BuildContext c) => inches(c).width;

  /// The height of the host device's display in inches.
  static double heightInches(BuildContext c) => inches(c).height;

  /// The diagonal measurement of the host device's display in inches.
  static double diagonalInches(BuildContext c) => diagonal(c) / _ppi;
}
