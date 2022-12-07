import 'package:flutter/material.dart';

/// The default light [ColorScheme] if the app is unable to build a dynamic Material color scheme.
final ColorScheme defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.yellow);

/// The default dark [ColorScheme] if the app is unable to build a dynamic Material color scheme.
final ColorScheme defaultDarkColorScheme =
    ColorScheme.fromSwatch(primarySwatch: Colors.yellow, brightness: Brightness.dark);
