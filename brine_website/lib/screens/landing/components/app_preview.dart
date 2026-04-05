import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app_preview/brine_device.dart';
import '../../../app_preview/light_theme_data.dart';
import '../../../app_preview/softener_monitor_view.dart';
import '../../../values/assets.dart';

/// Provides a preview of the Brine mobile app by running the app itself, which is included as a submodule, inside an
/// iPhone frame mockup.
///
/// So, this preview of the Brine app is not really a preview at all. It is actually the real app running within inside
/// an aesthetic frame. This fully takes advantage of the idea (which is wrong) that everything in Flutter is a widget.
class AppPreview extends StatefulWidget {
  /// Creates an instance of [AppPreview].
  const AppPreview({
    super.key,
  });

  @override
  State<AppPreview> createState() => _AppPreviewState();
}

/// The state for [AppPreview].
class _AppPreviewState extends State<AppPreview> {
  /// The height of the appliance used in the [SoftenerMonitorView] as a demonstration.
  static const double _applianceHeight = 1000;

  /// A timer used to change values in the [SoftenerMonitorView] periodically.
  late Timer _timer;

  /// The salt level value to use for the [SoftenerMonitorView] as a demonstration.
  double _saltLevel = 0.7;

  /// The salt distance value to use for the [SoftenerMonitorView] as a demonstration.
  double _saltDistance = _applianceHeight * _applianceHeight;

  /// The battery level value to use for the [SoftenerMonitorView] as a demonstration.
  double _batteryLevel = 0.6;

  /// Generates a random double value between a specified minimum and maximum value.
  ///
  /// This function takes in two double values, [minValue] and [maxValue], and returns a random double that falls
  /// between these values, inclusive of [minValue] and exclusive of [maxValue].
  ///
  /// Throws an [ArgumentError] if [maxValue] is less than [minValue].
  ///
  /// Example usage:
  /// ```dart
  /// double minValue = 1.5;
  /// double maxValue = 3.5;
  /// double randomValue = generateRandomDouble(minValue, maxValue);
  /// print('Random double between $minValue and $maxValue is $randomValue');
  /// ```
  ///
  /// [minValue] The minimum value that the random double can take, inclusive. [maxValue] The maximum value that the
  /// random double can take, exclusive.
  ///
  /// Returns a random double between [minValue] and [maxValue].
  double _generateRandomDouble(double minValue, double maxValue) {
    if (maxValue < minValue) {
      throw ArgumentError('maxValue should be greater than or equal to minValue');
    }

    final random = Random();
    return minValue + random.nextDouble() * (maxValue - minValue);
  }

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        // Generate new values
        _saltLevel = _generateRandomDouble(0.02, 0.95);
        _saltDistance = _applianceHeight * _saltLevel;
        _batteryLevel = _generateRandomDouble(0.4, 0.8);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Reference a view from the Brine mobile app
        Theme(
          data: lightThemeData,
          child: SizedBox(
            width: 300,
            height: 615,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              child: SoftenerMonitorView(
                device: BrineDevice(
                  name: 'Brine Device',
                  deviceId: 'slick_demo_device',
                  saltLevel: _saltLevel,
                  batteryLevel: _batteryLevel,
                  retrievalTimestamp: DateTime.now(),
                  saltDistance: _saltDistance,
                  applianceHeight: _applianceHeight,
                  lastUpdatedTimestamp: DateTime.now(),
                ),
              ),
            ),
          ),
        ),
        Image.asset(
          Asset.iphone13Mockup.path,
          width: 300,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
