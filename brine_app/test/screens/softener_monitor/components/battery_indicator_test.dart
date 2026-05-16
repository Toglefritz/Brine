import 'package:brine/screens/softener_monitor/softener_monitor_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [BatteryIndicator] widget.
///
/// Verifies that the correct battery icon is displayed for each battery level range and that the widget renders with
/// the expected color and rotation.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/softener_monitor/components/battery_indicator_test.dart
/// ```
void main() {
  group('BatteryIndicator', () {
    group('getBatteryIndicator icon selection', () {
      test('returns battery_1_bar when battery life is below 14%', () {
        const BatteryIndicator indicator = BatteryIndicator(batteryLife: 0.10);
        expect(indicator.getBatteryIndicator(), Icons.battery_1_bar);
      });

      test('returns battery_1_bar at the boundary (0.0)', () {
        const BatteryIndicator indicator = BatteryIndicator(batteryLife: 0.0);
        expect(indicator.getBatteryIndicator(), Icons.battery_1_bar);
      });

      test('returns battery_2_bar when battery life is between 14% and 28%', () {
        const BatteryIndicator indicator = BatteryIndicator(batteryLife: 0.20);
        expect(indicator.getBatteryIndicator(), Icons.battery_2_bar);
      });

      test('returns battery_3_bar when battery life is between 28% and 42%', () {
        const BatteryIndicator indicator = BatteryIndicator(batteryLife: 0.35);
        expect(indicator.getBatteryIndicator(), Icons.battery_3_bar);
      });

      test('returns battery_4_bar when battery life is between 42% and 56%', () {
        const BatteryIndicator indicator = BatteryIndicator(batteryLife: 0.50);
        expect(indicator.getBatteryIndicator(), Icons.battery_4_bar);
      });

      test('returns battery_5_bar when battery life is between 56% and 70%', () {
        const BatteryIndicator indicator = BatteryIndicator(batteryLife: 0.65);
        expect(indicator.getBatteryIndicator(), Icons.battery_5_bar);
      });

      test('returns battery_6_bar when battery life is between 70% and 84%', () {
        const BatteryIndicator indicator = BatteryIndicator(batteryLife: 0.75);
        expect(indicator.getBatteryIndicator(), Icons.battery_6_bar);
      });

      test('returns battery_full when battery life is 84% or above', () {
        const BatteryIndicator indicator = BatteryIndicator(batteryLife: 0.90);
        expect(indicator.getBatteryIndicator(), Icons.battery_full);
      });

      test('returns battery_full at full charge (1.0)', () {
        const BatteryIndicator indicator = BatteryIndicator(batteryLife: 1.0);
        expect(indicator.getBatteryIndicator(), Icons.battery_full);
      });
    });

    group('rendering', () {
      testWidgets('renders a RotatedBox with quarterTurns of 1', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BatteryIndicator(batteryLife: 0.5),
            ),
          ),
        );

        final Finder rotatedBox = find.byType(RotatedBox);
        expect(rotatedBox, findsOneWidget);

        final RotatedBox widget = tester.widget(rotatedBox);
        expect(widget.quarterTurns, 1);
      });

      testWidgets('renders an Icon with size 56', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BatteryIndicator(batteryLife: 0.5),
            ),
          ),
        );

        final Finder icon = find.byType(Icon);
        expect(icon, findsOneWidget);

        final Icon iconWidget = tester.widget(icon);
        expect(iconWidget.size, 56);
      });

      testWidgets('uses the default dark color when no color is provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BatteryIndicator(batteryLife: 0.5),
            ),
          ),
        );

        final Icon iconWidget = tester.widget(find.byType(Icon));
        expect(iconWidget.color, const Color(0xFF212121));
      });

      testWidgets('uses the provided color when specified', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BatteryIndicator(batteryLife: 0.5, color: Colors.red),
            ),
          ),
        );

        final Icon iconWidget = tester.widget(find.byType(Icon));
        expect(iconWidget.color, Colors.red);
      });

      testWidgets('displays the correct icon for the given battery level', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BatteryIndicator(batteryLife: 0.95),
            ),
          ),
        );

        final Icon iconWidget = tester.widget(find.byType(Icon));
        expect(iconWidget.icon, Icons.battery_full);
      });
    });
  });
}
