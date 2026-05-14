import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/account/account_route.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/test_brine_device.dart';

/// Tests for the [DeviceList] widget.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/account/components/device_list_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Helper to pump the [DeviceList] widget.
  Future<void> pumpDeviceList(
    WidgetTester tester, {
    required List<BrineDevice> devices,
    required void Function(String) onRemoveDevice,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          primaryColorDark: const Color(0xFF212121),
          cardColor: Colors.white,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 18),
            bodyMedium: TextStyle(fontSize: 14),
          ),
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: DeviceList(
              devices: devices,
              onRemoveDevice: onRemoveDevice,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('DeviceList', () {
    testWidgets('renders nothing when device list is empty', (tester) async {
      await pumpDeviceList(
        tester,
        devices: [],
        onRemoveDevice: (_) {},
      );

      // Should render a SizedBox.shrink (effectively nothing visible).
      expect(find.byType(DeviceList), findsOneWidget);
      expect(find.text('Brine Devices'), findsNothing);
    });

    testWidgets('displays the "Brine Devices" title when devices exist', (tester) async {
      final devices = [createTestDevice()];

      await pumpDeviceList(
        tester,
        devices: devices,
        onRemoveDevice: (_) {},
      );

      expect(find.text('Brine Devices'), findsOneWidget);
    });

    testWidgets('displays one ExpandableDeviceCard per device', (tester) async {
      final devices = [
        createTestDevice(deviceId: 'device_1', name: 'abc1'),
        createTestDevice(deviceId: 'device_2', name: 'def2'),
      ];

      await pumpDeviceList(
        tester,
        devices: devices,
        onRemoveDevice: (_) {},
      );

      // Each device should have its name displayed.
      expect(find.text('abc1'), findsOneWidget);
      expect(find.text('def2'), findsOneWidget);
    });

    testWidgets('displays three devices correctly', (tester) async {
      final devices = [
        createTestDevice(deviceId: 'device_1', name: 'aaa1'),
        createTestDevice(deviceId: 'device_2', name: 'bbb2'),
        createTestDevice(deviceId: 'device_3', name: 'ccc3'),
      ];

      await pumpDeviceList(
        tester,
        devices: devices,
        onRemoveDevice: (_) {},
      );

      expect(find.text('aaa1'), findsOneWidget);
      expect(find.text('bbb2'), findsOneWidget);
      expect(find.text('ccc3'), findsOneWidget);
    });
  });
}
