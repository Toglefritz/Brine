import 'package:brine/components/buttons/light_button.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/device_configuration/appliance_measurement/appliance_measurement_route.dart';
import 'package:brine/screens/device_configuration/brine_installation/brine_installation_route.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../appliance_measurement/helpers/mock_ble_communication_service.mocks.dart';

/// Tests for the [BrineInstallationRoute], its controller, and view.
///
/// This screen has no Firebase dependencies, so it can be tested directly without DI overrides.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/device_configuration/brine_installation/brine_installation_test.dart
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

  Future<void> pumpRoute(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BrineAppTheme.lightThemeData,
        darkTheme: BrineAppTheme.darkThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BrineInstallationRoute(
          bleCommunicationManager: MockBleCommunicationService(),
          device: createTestDevice(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('BrineInstallationRoute', () {
    group('view rendering', () {
      testWidgets('displays the "Install Brine" title', (WidgetTester tester) async {
        await pumpRoute(tester);

        expect(find.text('Install Brine'), findsOneWidget);
      });

      testWidgets('displays the continue button', (WidgetTester tester) async {
        await pumpRoute(tester);

        expect(find.byType(LightButton), findsOneWidget);
        expect(find.text('CONTINUE'), findsOneWidget);
      });

      testWidgets('renders a Scaffold', (WidgetTester tester) async {
        await pumpRoute(tester);

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('displays the placeholder icon', (WidgetTester tester) async {
        await pumpRoute(tester);

        expect(find.byIcon(Icons.square_foot), findsOneWidget);
      });
    });

    group('controller navigation', () {
      testWidgets('tapping continue navigates to ApplianceMeasurementRoute', (WidgetTester tester) async {
        await pumpRoute(tester);

        await tester.tap(find.text('CONTINUE'));
        await tester.pumpAndSettle();

        // After navigation, the BrineInstallationRoute should be replaced.
        expect(find.byType(BrineInstallationRoute), findsNothing);
        expect(find.byType(ApplianceMeasurementRoute), findsOneWidget);
      });
    });
  });
}
