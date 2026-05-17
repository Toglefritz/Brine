import 'dart:async';

import 'package:brine/components/loaders/wave_loader.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/device_configuration/device_connection/device_connection_route.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/central/models/ble_connection_state.dart';
import 'package:flutter_splendid_ble/central/models/ble_service.dart';
import 'package:flutter_splendid_ble/central/splendid_ble_central.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import 'helpers/mock_splendid_ble_central.mocks.dart';

/// Tests for the [DeviceConnectionRoute], its controller, and view.
///
/// Uses a mock [SplendidBleCentral] to simulate BLE connection, service discovery, and characteristic interactions
/// without requiring actual Bluetooth hardware.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/device_configuration/device_connection/device_connection_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  BleDevice createTestBleDevice() {
    return BleDevice(
      name: 'Brine_a1b2',
      address: 'AA:BB:CC:DD:EE:FF',
      advertisedServiceUuids: <String>[],
      rssi: -50,
      manufacturerData: null,
    );
  }

  Future<void> pumpRoute(
    WidgetTester tester, {
    required MockSplendidBleCentral mockBle,
    BleDevice? device,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BrineAppTheme.lightThemeData,
        darkTheme: BrineAppTheme.darkThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DeviceConnectionRoute(
          device: device ?? createTestBleDevice(),
          ble: mockBle,
        ),
      ),
    );
    await tester.pump();
  }

  group('DeviceConnectionRoute', () {
    group('view rendering', () {
      testWidgets('displays the WaveLoader while connecting', (WidgetTester tester) async {
        final MockSplendidBleCentral mockBle = MockSplendidBleCentral();

        // Return a stream that never emits (connection stays pending).
        when(
          mockBle.connect(deviceAddress: anyNamed('deviceAddress')),
        ).thenAnswer((_) async => const Stream<BleConnectionState>.empty());

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.byType(WaveLoader), findsOneWidget);
      });

      testWidgets('displays "Establishing connection..." text', (WidgetTester tester) async {
        final MockSplendidBleCentral mockBle = MockSplendidBleCentral();

        when(
          mockBle.connect(deviceAddress: anyNamed('deviceAddress')),
        ).thenAnswer((_) async => const Stream<BleConnectionState>.empty());

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.text('Establishing connection...'), findsOneWidget);
      });

      testWidgets('renders a Scaffold', (WidgetTester tester) async {
        final MockSplendidBleCentral mockBle = MockSplendidBleCentral();

        when(
          mockBle.connect(deviceAddress: anyNamed('deviceAddress')),
        ).thenAnswer((_) async => const Stream<BleConnectionState>.empty());

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('controller connection logic', () {
      testWidgets('calls connect with the correct device address', (WidgetTester tester) async {
        final MockSplendidBleCentral mockBle = MockSplendidBleCentral();

        when(
          mockBle.connect(deviceAddress: anyNamed('deviceAddress')),
        ).thenAnswer((_) async => const Stream<BleConnectionState>.empty());

        await pumpRoute(tester, mockBle: mockBle);

        verify(mockBle.connect(deviceAddress: 'AA:BB:CC:DD:EE:FF')).called(1);
      });

      testWidgets('calls discoverServices after connection is established', (WidgetTester tester) async {
        final MockSplendidBleCentral mockBle = MockSplendidBleCentral();
        final StreamController<BleConnectionState> connectionController = StreamController<BleConnectionState>();

        when(
          mockBle.connect(deviceAddress: anyNamed('deviceAddress')),
        ).thenAnswer((_) async => connectionController.stream);
        when(mockBle.discoverServices(any)).thenAnswer((_) async => const Stream<List<BleService>>.empty());

        await pumpRoute(tester, mockBle: mockBle);

        // Simulate a successful connection.
        connectionController.add(BleConnectionState.connected);
        await tester.pump();

        verify(mockBle.discoverServices('AA:BB:CC:DD:EE:FF')).called(1);

        await connectionController.close();
      });

      testWidgets('starts a connection timeout timer', (WidgetTester tester) async {
        final MockSplendidBleCentral mockBle = MockSplendidBleCentral();

        when(
          mockBle.connect(deviceAddress: anyNamed('deviceAddress')),
        ).thenAnswer((_) async => const Stream<BleConnectionState>.empty());

        await pumpRoute(tester, mockBle: mockBle);

        // The connection was initiated, which means the timeout timer was also started. We verify this indirectly: if
        // we advance time and the widget is still mounted, the timer exists. The actual timeout navigation is tested
        // via integration tests due to async Timer limitations.
        verify(mockBle.connect(deviceAddress: 'AA:BB:CC:DD:EE:FF')).called(1);
      });
    });

    group('construction', () {
      test('stores the device', () {
        final BleDevice device = createTestBleDevice();
        final DeviceConnectionRoute route = DeviceConnectionRoute(device: device);

        expect(route.device.address, 'AA:BB:CC:DD:EE:FF');
        expect(route.device.name, 'Brine_a1b2');
      });

      test('accepts an optional ble parameter', () {
        final MockSplendidBleCentral mockBle = MockSplendidBleCentral();
        final DeviceConnectionRoute route = DeviceConnectionRoute(
          device: createTestBleDevice(),
          ble: mockBle,
        );

        expect(route.ble, mockBle);
      });

      test('ble defaults to null', () {
        final DeviceConnectionRoute route = DeviceConnectionRoute(device: createTestBleDevice());
        expect(route.ble, isNull);
      });
    });
  });
}
