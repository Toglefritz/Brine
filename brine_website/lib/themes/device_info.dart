import 'dart:io';

import 'package:flutter/foundation.dart';

/// Provides information about the host device running the application.
class DeviceInfo {
  /// Determines if the host platform is a desktop environment on any operating system.
  static bool get isDesktop => !isWeb && (isWindows || isLinux || isMacOS);

  /// Determines if the host platform is a mobile environment on any opperating system.
  static bool get isMobile => isAndroid || isIOS;

  /// Determines if the host platform is a website.
  static bool get isWeb => kIsWeb;

  /// Determines if the host platform is a Windows OS environment.
  static bool get isWindows => Platform.isWindows;

  /// Determines if the host platform is a Linux OS environment.
  static bool get isLinux => Platform.isLinux;

  /// Determines if the host platform is a MacOS environment.
  static bool get isMacOS => Platform.isMacOS;

  /// Determines if the host platform is an Android environment.
  static bool get isAndroid => Platform.isAndroid;

  /// Determines if the host platform is a Fuchsia environment.
  static bool get isFuchsia => Platform.isFuchsia;

  /// Determines if the host platform is an iOS environment.
  static bool get isIOS => Platform.isIOS;
}
