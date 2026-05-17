import 'package:brine/components/loaders/wave_loader.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/device_configuration/wifi_setup/wifi_setup_route.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import '../appliance_measurement/helpers/mock_ble_communication_service.mocks.dart';

/// Tests for the [WiFiSetupRoute], its controller, and view.
///
/// This screen sends a scan command to the Brine device, receives a list of WiFi networks, and displays them for the
/// user to select. No Firebase dependencies.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/device_configuration/wifi_setup/wifi_setup_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  BrineDevice createTestDevice() {
    return BrineDevice(
      deviceId: 'test_device_id',
      name: 'dev0',
      saltDistance: 150,
      applianceHeight: 300,
      saltLevel: 0.5,
      batteryLevel: 0.8,
      lastUpdatedTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
      retrievalTimestamp: DateTime.now(),
    );
  }

  Future<void> pumpRoute(WidgetTester tester, {required MockBleCommunicationService mockBle}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BrineAppTheme.lightThemeData,
        darkTheme: BrineAppTheme.darkThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WiFiSetupRoute(
          device: createTestDevice(),
          bleCommunicationManager: mockBle,
        ),
      ),
    );
    await tester.pump();
  }

  group('WiFiSetupRoute', () {
    group('loading state', () {
      testWidgets('displays the WaveLoader while waiting for networks', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.byType(WaveLoader), findsOneWidget);
      });

      testWidgets('displays the "WiFi Setup" title', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.text('WiFi Setup'), findsOneWidget);
      });

      testWidgets('displays the setup instructions', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        expect(
          find.text('Select the WiFi network to which your Brine monitor should connect.'),
          findsOneWidget,
        );
      });

      testWidgets('renders a Scaffold', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('controller business logic', () {
      testWidgets('sends the scan command via BLE on init', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        final VerificationResult result = verify(mockBle.writeValue(value: captureAnyNamed('value')));
        result.called(1);

        final String commandString = result.captured.single as String;
        expect(commandString, contains('scan'));
      });

      testWidgets('registers a callback on the BLE service', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        verify(mockBle.registerCallback(any)).called(1);
      });

      testWidgets('displays network list after receiving scan results', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        // Capture the registered callback and invoke it with scan results.
        final dynamic captured = verify(mockBle.registerCallback(captureAny)).captured.single;
        final void Function(Map<String, dynamic>) callback = captured as void Function(Map<String, dynamic>);

        // Simulate the BLE device responding with a list of WiFi networks.
        callback({
          'networks': [
            {'ssid': 'HomeNetwork', 'rssi': -45},
            {'ssid': 'OfficeWiFi', 'rssi': -65},
            {'ssid': 'WeakSignal', 'rssi': -85},
          ],
        });
        await tester.pump();

        // The network names should be displayed.
        expect(find.text('HomeNetwork'), findsOneWidget);
        expect(find.text('OfficeWiFi'), findsOneWidget);
        expect(find.text('WeakSignal'), findsOneWidget);

        // The WaveLoader should no longer be visible.
        expect(find.byType(WaveLoader), findsNothing);
      });

      testWidgets('displays "No networks detected" when scan returns empty list', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        // Capture and invoke the callback with an empty network list.
        final dynamic captured = verify(mockBle.registerCallback(captureAny)).captured.single;
        final void Function(Map<String, dynamic>) callback = captured as void Function(Map<String, dynamic>);

        callback({'networks': <Map<String, dynamic>>[]});
        await tester.pump();

        expect(find.text('No networks detected'), findsOneWidget);
        expect(find.byIcon(Icons.signal_wifi_off), findsOneWidget);
      });

      testWidgets('displays signal strength icons for each network', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        final dynamic captured = verify(mockBle.registerCallback(captureAny)).captured.single;
        final void Function(Map<String, dynamic>) callback = captured as void Function(Map<String, dynamic>);

        callback({
          'networks': [
            {'ssid': 'StrongSignal', 'rssi': -40},
          ],
        });
        await tester.pump();

        // A strong signal (-40 dBm) should show the full WiFi icon.
        expect(find.byIcon(Icons.signal_wifi_4_bar), findsOneWidget);
      });
    });

    group('construction', () {
      test('stores the device', () {
        final BrineDevice device = createTestDevice();
        final WiFiSetupRoute route = WiFiSetupRoute(
          device: device,
          bleCommunicationManager: MockBleCommunicationService(),
        );

        expect(route.device.deviceId, 'test_device_id');
      });
    });
  });
}
