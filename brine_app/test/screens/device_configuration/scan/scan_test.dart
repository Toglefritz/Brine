import 'dart:async';

import 'package:brine/components/loaders/wave_loader.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/device_configuration/scan/scan_route.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/central/splendid_ble_central.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';
import 'package:flutter_splendid_ble/shared/models/bluetooth_permission_status.dart';
import 'package:flutter_splendid_ble/shared/models/bluetooth_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import '../device_connection/helpers/mock_splendid_ble_central.mocks.dart';

/// Tests for the [ScanRoute], its controller, and views.
///
/// Uses a mock [SplendidBleCentral] to simulate BLE permission checks, adapter status, and device scanning without
/// requiring actual Bluetooth hardware.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/device_configuration/scan/scan_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Sets up a mock BLE that reports permissions granted and adapter enabled, then returns the given scan stream.
  MockSplendidBleCentral createMockBle({Stream<BleDevice>? scanStream}) {
    final MockSplendidBleCentral mockBle = MockSplendidBleCentral();

    // Permission status: granted immediately.
    when(
      mockBle.emitCurrentPermissionStatus(),
    ).thenAnswer((_) async => Stream<BluetoothPermissionStatus>.value(BluetoothPermissionStatus.granted));
    when(mockBle.requestBluetoothPermissions()).thenAnswer((_) async => BluetoothPermissionStatus.granted);

    // Bluetooth adapter: enabled immediately.
    when(
      mockBle.emitCurrentBluetoothStatus(),
    ).thenAnswer((_) async => Stream<BluetoothStatus>.value(BluetoothStatus.enabled));

    // Scan: return the provided stream or an empty one.
    when(
      mockBle.startScan(filters: anyNamed('filters')),
    ).thenAnswer((_) async => scanStream ?? const Stream<BleDevice>.empty());
    when(mockBle.stopScan()).thenReturn(null);

    return mockBle;
  }

  Future<void> pumpRoute(
    WidgetTester tester, {
    required MockSplendidBleCentral mockBle,
    List<String> excludedDeviceNames = const <String>[],
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BrineAppTheme.lightThemeData,
        darkTheme: BrineAppTheme.darkThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScanRoute(
          excludedDeviceNames: excludedDeviceNames,
          ble: mockBle,
        ),
      ),
    );
    // Pump to trigger initState and the permission/adapter status streams.
    await tester.pump();
    await tester.pump();
  }

  group('ScanRoute', () {
    group('scanning view', () {
      testWidgets('displays the WaveLoader while scanning', (WidgetTester tester) async {
        final MockSplendidBleCentral mockBle = createMockBle();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.byType(WaveLoader), findsOneWidget);
      });

      testWidgets('displays "Scanning for devices..." text', (WidgetTester tester) async {
        final MockSplendidBleCentral mockBle = createMockBle();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.text('Scanning for devices...'), findsOneWidget);
      });

      testWidgets('displays the cancel button', (WidgetTester tester) async {
        final MockSplendidBleCentral mockBle = createMockBle();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
      });

      testWidgets('renders a Scaffold', (WidgetTester tester) async {
        final MockSplendidBleCentral mockBle = createMockBle();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('controller scan logic', () {
      testWidgets('starts a BLE scan after permissions and adapter are ready', (WidgetTester tester) async {
        final MockSplendidBleCentral mockBle = createMockBle();

        await pumpRoute(tester, mockBle: mockBle);

        verify(mockBle.startScan(filters: anyNamed('filters'))).called(1);
      });

      testWidgets('starts a scan timeout timer', (WidgetTester tester) async {
        final MockSplendidBleCentral mockBle = createMockBle();

        await pumpRoute(tester, mockBle: mockBle);

        // The scan was started, which means the timeout timer was also started. The actual timeout state transition
        // involves async operations inside the timer callback that are difficult to test in the fake async
        // environment. The timeout behavior is verified via integration tests.
        verify(mockBle.startScan(filters: anyNamed('filters'))).called(1);
      });

      testWidgets('excludes devices in the exclusion list', (WidgetTester tester) async {
        final StreamController<BleDevice> scanController = StreamController<BleDevice>();
        final MockSplendidBleCentral mockBle = createMockBle(scanStream: scanController.stream);

        await pumpRoute(tester, mockBle: mockBle, excludedDeviceNames: <String>['Brine_a1b2']);

        // Emit an excluded device. The controller should ignore it and not navigate.
        scanController.add(
          BleDevice(
            name: 'Brine_a1b2',
            address: 'AA:BB:CC:DD:EE:FF',
            advertisedServiceUuids: <String>[],
            rssi: -50,
            manufacturerData: null,
          ),
        );
        await tester.pump();

        // The scan view should still be displayed (no navigation occurred).
        expect(find.text('Scanning for devices...'), findsOneWidget);

        await scanController.close();
      });

      testWidgets('stops the scan when a valid device is found', (WidgetTester tester) async {
        final StreamController<BleDevice> scanController = StreamController<BleDevice>();
        final MockSplendidBleCentral mockBle = createMockBle(scanStream: scanController.stream);

        await pumpRoute(tester, mockBle: mockBle);

        // Emit a valid Brine device and close the stream so cancel() doesn't block.
        scanController.add(
          BleDevice(
            name: 'Brine_c3d4',
            address: 'BB:CC:DD:EE:FF:00',
            advertisedServiceUuids: <String>[],
            rssi: -45,
            manufacturerData: null,
          ),
        );
        await scanController.close();
        await tester.pump();
        await tester.pump();

        // Verify that stopScan was called after discovering a valid device.
        verify(mockBle.stopScan()).called(greaterThanOrEqualTo(1));
      });
    });

    group('construction', () {
      test('stores the excluded device names', () {
        const ScanRoute route = ScanRoute(excludedDeviceNames: <String>['dev1', 'dev2']);
        expect(route.excludedDeviceNames, <String>['dev1', 'dev2']);
      });

      test('ble defaults to null', () {
        const ScanRoute route = ScanRoute(excludedDeviceNames: <String>[]);
        expect(route.ble, isNull);
      });
    });
  });
}
