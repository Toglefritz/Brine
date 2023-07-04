import 'dart:async';
import 'dart:math';

import 'package:brine/screens/softener_monitor/softener_monitor_route.dart';
import 'package:brine/services/firebase/models/brine_device.dart';
import 'package:brine/theme/themes.dart';
import 'package:flutter/material.dart';

import '../../../values/assets.dart';

/// Provides a preview of the Brine mobile app by running the app itself, which is included as a submodule, inside
/// an iPhone frame mockup.
///
/// So, this preview of the Brine app is not really a preview at all. It is actually the real app running within inside
/// an aesthetic frame. This fully takes advantage of the idea (which is wrong) that everything in Flutter is a widget.
class AppPreview extends StatefulWidget {
  const AppPreview({
    super.key,
  });

  @override
  State<AppPreview> createState() => _AppPreviewState();
}

class _AppPreviewState extends State<AppPreview> {
  /// A timer used to change values in the [SoftenerMonitorRoute] periodically.
  late Timer _timer;

  /// The salt level value to use for the [SoftenerMonitorRoute] as a demonstration.
  double saltLevel = 0.7;

  /// The battery level value to use for the [SoftenerMonitorRoute] as a demonstration.
  double batteryLevel = 0.6;

  /// Generates a random double value between a specified minimum and maximum value.
  ///
  /// This function takes in two double values, [minValue] and [maxValue], and returns
  /// a random double that falls between these values, inclusive of [minValue] and exclusive of [maxValue].
  ///
  /// Throws an [ArgumentError] if [maxValue] is less than [minValue].
  ///
  /// Example usage:
  /// ```
  /// double minValue = 1.5;
  /// double maxValue = 3.5;
  /// double randomValue = generateRandomDouble(minValue, maxValue);
  /// print('Random double between $minValue and $maxValue is $randomValue');
  /// ```
  ///
  /// [minValue] The minimum value that the random double can take, inclusive.
  /// [maxValue] The maximum value that the random double can take, exclusive.
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
        saltLevel = _generateRandomDouble(0.1, 0.9);
        batteryLevel = _generateRandomDouble(0.4, 0.8);
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
          data: lightThemeData.copyWith(
            scaffoldBackgroundColor: const Color(0xFFFFF0D1),
          ),
          child: SizedBox(
            width: 300,
            height: 615,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              child: SoftenerMonitorRoute(
                devices: [
                  BrineDevice(
                    deviceId: 'slick_demo_device',
                    saltLevel: saltLevel,
                    batteryLevel: batteryLevel,
                    retrievalTimestamp: DateTime.now(),
                  )
                ],
              ),
            ),
          ),
        ),
        Image.asset(
          Assets.iphone13Mockup.path,
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
