import 'package:brine/components/loaders/wave_loader.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/device_configuration/brine_installation/brine_installation_route.dart';
import 'package:brine/screens/device_configuration/wifi_connection/wifi_connection_route.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import '../appliance_measurement/helpers/mock_ble_communication_service.mocks.dart';

/// Tests for the [WiFiConnectionRoute], its controller, and view.
///
/// This screen sends a WiFi connect command to the Brine device via BLE and waits for a response. The view displays a
/// loading indicator while the connection attempt is in progress.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/device_configuration/wifi_connection/wifi_connection_test.dart
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
        home: WiFiConnectionRoute(
          bleCommunicationManager: mockBle,
          ssid: 'TestNetwork',
          password: 'secret123',
          device: createTestDevice(),
        ),
      ),
    );
    await tester.pump();
  }

  group('WiFiConnectionRoute', () {
    group('view rendering', () {
      testWidgets('displays the WaveLoader while connecting', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.byType(WaveLoader), findsOneWidget);
      });

      testWidgets('displays "Connecting to WiFi..." text', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.text('Connecting to WiFi...'), findsOneWidget);
      });

      testWidgets('renders a Scaffold', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('controller business logic', () {
      testWidgets('sends the wifi connect command with SSID and password', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        // Verify that writeValue was called with a command containing the SSID and password.
        final VerificationResult result = verify(mockBle.writeValue(value: captureAnyNamed('value')));
        result.called(1);

        final String commandString = result.captured.single as String;
        expect(commandString, contains('wifi_connect'));
        expect(commandString, contains('TestNetwork'));
        expect(commandString, contains('secret123'));
      });

      testWidgets('registers a callback on the BLE service', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        verify(mockBle.registerCallback(any)).called(1);
      });

      testWidgets('navigates to BrineInstallationRoute on successful WiFi connection', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        // Capture the registered callback and invoke it with a success response.
        final dynamic captured = verify(mockBle.registerCallback(captureAny)).captured.single;
        final void Function(Map<String, dynamic>) callback = captured as void Function(Map<String, dynamic>);

        // Simulate the BLE device responding with a successful WiFi connection.
        callback({'response': 'wifi_connected', 'ssid': 'TestNetwork'});
        await tester.pumpAndSettle();

        // The WiFiConnectionRoute should be replaced by BrineInstallationRoute.
        expect(find.byType(WiFiConnectionRoute), findsNothing);
        expect(find.byType(BrineInstallationRoute), findsOneWidget);
      });

      testWidgets('shows error dialog on WiFi connection failure', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        // Capture the registered callback and invoke it with an error response.
        final dynamic captured = verify(mockBle.registerCallback(captureAny)).captured.single;
        final void Function(Map<String, dynamic>) callback = captured as void Function(Map<String, dynamic>);

        // Simulate the BLE device responding with a WiFi connection error.
        callback({'response': 'wifi_connect_error', 'message': 'Wrong password'});
        await tester.pump();
        await tester.pump();

        // An error dialog should be displayed.
        expect(find.text('WiFi Connection Failed'), findsOneWidget);
        expect(find.textContaining('TestNetwork'), findsOneWidget);
        expect(find.textContaining('Wrong password'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);
      });
    });

    group('construction', () {
      test('stores the SSID and password', () {
        final WiFiConnectionRoute route = WiFiConnectionRoute(
          bleCommunicationManager: MockBleCommunicationService(),
          ssid: 'MyNetwork',
          password: 'pass123',
          device: createTestDevice(),
        );

        expect(route.ssid, 'MyNetwork');
        expect(route.password, 'pass123');
      });
    });
  });
}
