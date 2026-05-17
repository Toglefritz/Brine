import 'package:brine/components/buttons/light_button.dart';
import 'package:brine/components/loaders/wave_loader.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/device_configuration/provisioning_complete/provisioning_complete_route.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import '../appliance_measurement/helpers/mock_ble_communication_service.mocks.dart';

/// Tests for the [ProvisioningCompleteRoute], its controller, and views.
///
/// This screen has no Firebase dependencies. The controller sends a BLE command on init and transitions between a
/// loading view and a success view based on the BLE device's response.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/device_configuration/provisioning_complete/provisioning_complete_test.dart
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
        home: ProvisioningCompleteRoute(
          bleCommunicationManager: mockBle,
          device: createTestDevice(),
        ),
      ),
    );
    await tester.pump();
  }

  group('ProvisioningCompleteRoute', () {
    group('loading view', () {
      testWidgets('displays the WaveLoader while waiting for device response', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.byType(WaveLoader), findsOneWidget);
      });

      testWidgets('displays "Completing setup..." text', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.text('Completing setup...'), findsOneWidget);
      });

      testWidgets('renders a Scaffold', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('controller business logic', () {
      testWidgets('sends the completeProvisioning command via BLE on init', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        // Verify that writeValue was called (the provisioning complete command).
        verify(mockBle.writeValue(value: anyNamed('value'))).called(1);
      });

      testWidgets('registers a callback on the BLE service', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        verify(mockBle.registerCallback(any)).called(1);
      });

      testWidgets('transitions to the complete view when device responds with success', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        // Initially shows the loading view.
        expect(find.text('Completing setup...'), findsOneWidget);
        expect(find.text('Setup complete'), findsNothing);

        // Capture the registered callback and invoke it with a success response.
        final dynamic captured = verify(mockBle.registerCallback(captureAny)).captured.single;
        final void Function(Map<String, dynamic>) callback = captured as void Function(Map<String, dynamic>);

        // Simulate the BLE device responding with a successful provisioning complete message.
        callback({'response': 'provisioning_complete'});
        await tester.pump();

        // The view should now show the success state.
        expect(find.text('Setup complete'), findsOneWidget);
        expect(find.text('Completing setup...'), findsNothing);
      });

      testWidgets('displays the Done button after provisioning completes', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        // Capture and invoke the callback with success.
        final dynamic captured = verify(mockBle.registerCallback(captureAny)).captured.single;
        final void Function(Map<String, dynamic>) callback = captured as void Function(Map<String, dynamic>);
        callback({'response': 'provisioning_complete'});
        await tester.pump();

        expect(find.byType(LightButton), findsOneWidget);
        expect(find.text('DONE'), findsOneWidget);
      });

      testWidgets('displays the check icon after provisioning completes', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        // Capture and invoke the callback with success.
        final dynamic captured = verify(mockBle.registerCallback(captureAny)).captured.single;
        final void Function(Map<String, dynamic>) callback = captured as void Function(Map<String, dynamic>);
        callback({'response': 'provisioning_complete'});
        await tester.pump();

        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('disposes the BLE communication manager on success', (WidgetTester tester) async {
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(tester, mockBle: mockBle);

        // Capture and invoke the callback with success.
        final dynamic captured = verify(mockBle.registerCallback(captureAny)).captured.single;
        final void Function(Map<String, dynamic>) callback = captured as void Function(Map<String, dynamic>);
        callback({'response': 'provisioning_complete'});
        await tester.pump();

        // Verify that dispose was called on the BLE service to terminate the connection.
        verify(mockBle.dispose()).called(1);
      });
    });
  });
}
