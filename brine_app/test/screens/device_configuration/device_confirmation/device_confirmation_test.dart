import 'package:brine/components/buttons/light_button.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/device_configuration/device_confirmation/device_confirmation_route.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tests for the [DeviceConfirmationRoute], its controller, and view.
///
/// This screen has no Firebase dependencies, so it can be tested directly.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/device_configuration/device_confirmation/device_confirmation_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Creates a test [BleDevice] with a name that follows the Brine naming convention (e.g. "Brine_a1b2").
  BleDevice createTestBleDevice({String name = 'Brine_a1b2'}) {
    return BleDevice(
      name: name,
      address: 'AA:BB:CC:DD:EE:FF',
      advertisedServiceUuids: <String>[],
      rssi: -50,
      manufacturerData: null,
    );
  }

  Future<void> pumpRoute(
    WidgetTester tester, {
    BleDevice? device,
    List<String> excludedDevices = const <String>[],
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BrineAppTheme.lightThemeData,
        darkTheme: BrineAppTheme.darkThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DeviceConfirmationRoute(
          device: device ?? createTestBleDevice(),
          excludedDevices: excludedDevices,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('DeviceConfirmationRoute', () {
    group('view rendering', () {
      testWidgets('displays the "Device detected" title', (WidgetTester tester) async {
        await pumpRoute(tester);

        expect(find.text('Device detected'), findsOneWidget);
      });

      testWidgets('displays the confirmation question', (WidgetTester tester) async {
        await pumpRoute(tester);

        expect(find.text('Is this the device you wish to add?'), findsOneWidget);
      });

      testWidgets('displays the device name suffix', (WidgetTester tester) async {
        await pumpRoute(tester, device: createTestBleDevice(name: 'Brine_c3d4'));

        // The view shows device.name.substring(6), which is "c3d4" for "Brine_c3d4".
        expect(find.text('c3d4'), findsOneWidget);
      });

      testWidgets('displays the device address when name is null', (WidgetTester tester) async {
        final BleDevice device = BleDevice(
          name: null,
          address: 'AA:BB:CC:DD:EE:FF',
          advertisedServiceUuids: <String>[],
          rssi: -50,
          manufacturerData: null,
        );

        await pumpRoute(tester, device: device);

        expect(find.text('AA:BB:CC:DD:EE:FF'), findsOneWidget);
      });

      testWidgets('displays the continue button', (WidgetTester tester) async {
        await pumpRoute(tester);

        expect(find.text('CONTINUE'), findsOneWidget);
      });

      testWidgets('displays the choose another button', (WidgetTester tester) async {
        await pumpRoute(tester);

        expect(find.text('CHOOSE ANOTHER'), findsOneWidget);
      });

      testWidgets('renders two LightButton widgets', (WidgetTester tester) async {
        await pumpRoute(tester);

        expect(find.byType(LightButton), findsNWidgets(2));
      });

      testWidgets('renders a Scaffold', (WidgetTester tester) async {
        await pumpRoute(tester);

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('controller navigation', () {
      testWidgets('continue button has an onPressed callback', (WidgetTester tester) async {
        await pumpRoute(tester);

        // Verify the continue button is wired to a callback.
        final Finder continueButton = find.ancestor(
          of: find.text('CONTINUE'),
          matching: find.byType(LightButton),
        );
        expect(continueButton, findsOneWidget);
      });

      testWidgets('choose another button has an onPressed callback', (WidgetTester tester) async {
        await pumpRoute(tester);

        // Verify the choose another button is wired to a callback.
        final Finder chooseAnotherButton = find.ancestor(
          of: find.text('CHOOSE ANOTHER'),
          matching: find.byType(LightButton),
        );
        expect(chooseAnotherButton, findsOneWidget);
      });
    });

    group('construction', () {
      test('stores the device', () {
        final BleDevice device = createTestBleDevice();
        final DeviceConfirmationRoute route = DeviceConfirmationRoute(
          device: device,
          excludedDevices: const <String>[],
        );

        expect(route.device.name, 'Brine_a1b2');
        expect(route.device.address, 'AA:BB:CC:DD:EE:FF');
      });

      test('stores the excluded devices list', () {
        final DeviceConfirmationRoute route = DeviceConfirmationRoute(
          device: createTestBleDevice(),
          excludedDevices: const <String>['prev_device'],
        );

        expect(route.excludedDevices, contains('prev_device'));
      });
    });
  });
}
