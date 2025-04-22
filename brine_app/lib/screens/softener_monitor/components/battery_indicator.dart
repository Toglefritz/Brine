import 'package:flutter/material.dart';

/// Displays an icon to indicate the remaining battery life on the Brine monitor.
class BatteryIndicator extends StatelessWidget {
  /// Creates an instance of [BatteryIndicator].
  const BatteryIndicator({
    required this.batteryLife,
    super.key,
  });

  /// The percentage of battery life remaining on the device.
  final double batteryLife;

  /// Returns an icon to indicate the current battery life.
  IconData _getBatteryIndicator() {
    if (batteryLife < 0.14) {
      return Icons.battery_1_bar;
    } else if (batteryLife < .28) {
      return Icons.battery_2_bar;
    } else if (batteryLife < .42) {
      return Icons.battery_3_bar;
    } else if (batteryLife < 0.56) {
      return Icons.battery_4_bar;
    } else if (batteryLife < 0.7) {
      return Icons.battery_5_bar;
    } else if (batteryLife < .84) {
      return Icons.battery_6_bar;
    } else {
      return Icons.battery_full;
    }
  }

  /// Returns the color to use for the battery indicator icon.
  Color _getBatteryColor(BuildContext context) {
    if (batteryLife < 0.14) {
      return Colors.red[900]!;
    } else {
      return const Color(0xFF212121);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: Icon(
        _getBatteryIndicator(),
        color: _getBatteryColor(context),
        size: 56,
      ),
    );
  }
}
