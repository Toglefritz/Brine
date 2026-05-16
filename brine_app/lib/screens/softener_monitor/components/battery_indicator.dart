part of '../softener_monitor_route.dart';

/// Displays an icon to indicate the remaining battery life on the Brine monitor.
class BatteryIndicator extends StatelessWidget {
  /// Creates an instance of [BatteryIndicator].
  const BatteryIndicator({
    required this.batteryLife,
    this.color,
    super.key,
  });

  /// The percentage of battery life remaining on the device.
  final double batteryLife;

  /// The color of the battery indicator.
  final Color? color;

  /// Returns an icon to indicate the current battery life.
  IconData getBatteryIndicator() {
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

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: Icon(
        getBatteryIndicator(),
        color: color ?? const Color(0xFF212121),
        size: 56,
      ),
    );
  }
}
