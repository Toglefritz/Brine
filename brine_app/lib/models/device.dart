// Ignore coverage since this file is entirely dependent on the platform. coverage:ignore-file

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Syntactic sugar for different characteristics of the host device.
// ignore_for_file: public_member_api_docs
class Device {
  // Device size
  static bool get isDesktop => !isWeb && (isWindows || isLinux || isMacOS);
  static bool get isMobile => isAndroid || isIOS;
  static bool get isWeb => kIsWeb;

  // Platform
  static bool get isWindows => Platform.isWindows;
  static bool get isLinux => Platform.isLinux;
  static bool get isMacOS => Platform.isMacOS;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isFuchsia => Platform.isFuchsia;
  static bool get isIOS => Platform.isIOS;
}
