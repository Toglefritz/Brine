import 'package:brine/components/buttons/light_button.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/softener_monitor/softener_monitor_route.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tests for the [SoftenerMonitorRoute], [SoftenerMonitorController], and [SoftenerMonitorView].
///
/// Because the [WaveProgressIndicator] uses a repeating animation, all tests use `tester.pump()` with explicit
/// durations rather than `tester.pumpAndSettle()`.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/softener_monitor/softener_monitor_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Pumps the [SoftenerMonitorRoute] with the given devices.
  Future<void> pumpRoute(
    WidgetTester tester, {
    required List<BrineDevice> devices,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BrineAppTheme.lightThemeData,
        darkTheme: BrineAppTheme.darkThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SoftenerMonitorRoute(devices: devices),
      ),
    );
    await tester.pump();
  }

  /// Creates a [BrineDevice] with a recent update timestamp (not overdue).
  BrineDevice createRecentDevice({
    String deviceId = 'test_device',
    String name = 'dev0',
    double saltLevel = 0.5,
    double batteryLevel = 0.8,
  }) {
    return BrineDevice(
      deviceId: deviceId,
      name: name,
      saltDistance: 150,
      applianceHeight: 300,
      saltLevel: saltLevel,
      batteryLevel: batteryLevel,
      lastUpdatedTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
      retrievalTimestamp: DateTime.now(),
    );
  }

  /// Creates a [BrineDevice] with an overdue update timestamp (more than 3 days old).
  BrineDevice createOverdueDevice({
    String deviceId = 'overdue_device',
    String name = 'old0',
    double saltLevel = 0.3,
    double batteryLevel = 0.6,
  }) {
    return BrineDevice(
      deviceId: deviceId,
      name: name,
      saltDistance: 90,
      applianceHeight: 300,
      saltLevel: saltLevel,
      batteryLevel: batteryLevel,
      lastUpdatedTimestamp: DateTime.now().subtract(const Duration(days: 5)),
      retrievalTimestamp: DateTime.now(),
    );
  }

  group('SoftenerMonitorController', () {
    group('initial state', () {
      testWidgets('selects the first device by default', (WidgetTester tester) async {
        final List<BrineDevice> devices = [
          createRecentDevice(deviceId: 'first', name: 'aaa0'),
          createRecentDevice(deviceId: 'second', name: 'bbb1'),
        ];

        await pumpRoute(tester, devices: devices);

        // The first device's salt level should be displayed.
        expect(find.text('50%'), findsOneWidget);
      });

      testWidgets('renders the normal view when device update is recent', (WidgetTester tester) async {
        await pumpRoute(tester, devices: [createRecentDevice()]);

        // The normal view displays the WaveProgressIndicator.
        final Finder wavePaint = find.byWidgetPredicate(
          (Widget widget) => widget is CustomPaint && widget.painter is WavePainter,
        );
        expect(wavePaint, findsOneWidget);
      });

      testWidgets('renders the overdue view when device update is overdue', (WidgetTester tester) async {
        await pumpRoute(tester, devices: [createOverdueDevice()]);

        // The overdue view displays the reconnect button.
        expect(find.text('RECONNECT'), findsOneWidget);
      });
    });

    group('route construction', () {
      test('stores the devices list', () {
        final List<BrineDevice> devices = [
          createRecentDevice(deviceId: 'a'),
          createRecentDevice(deviceId: 'b'),
        ];

        final SoftenerMonitorRoute route = SoftenerMonitorRoute(devices: devices);
        expect(route.devices.length, 2);
        expect(route.devices[0].deviceId, 'a');
        expect(route.devices[1].deviceId, 'b');
      });
    });
  });

  group('SoftenerMonitorView', () {
    group('salt level display', () {
      testWidgets('displays the salt level as a percentage', (WidgetTester tester) async {
        await pumpRoute(tester, devices: [createRecentDevice(saltLevel: 0.75)]);

        expect(find.text('75%'), findsOneWidget);
      });

      testWidgets('displays "SALT REMAINING" label', (WidgetTester tester) async {
        await pumpRoute(tester, devices: [createRecentDevice()]);

        expect(find.text('SALT REMAINING'), findsOneWidget);
      });

      testWidgets('displays warning icon when salt level is 10% or below', (WidgetTester tester) async {
        await pumpRoute(tester, devices: [createRecentDevice(saltLevel: 0.08)]);

        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      });

      testWidgets('does not display warning icon when salt level is above 10%', (WidgetTester tester) async {
        await pumpRoute(tester, devices: [createRecentDevice()]);

        expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      });
    });

    group('battery indicator', () {
      testWidgets('displays the BatteryIndicator widget', (WidgetTester tester) async {
        await pumpRoute(tester, devices: [createRecentDevice(batteryLevel: 0.9)]);

        expect(find.byType(BatteryIndicator), findsOneWidget);
      });
    });

    group('layout structure', () {
      testWidgets('renders a Scaffold', (WidgetTester tester) async {
        await pumpRoute(tester, devices: [createRecentDevice()]);

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('renders the SoftenerMonitorAppBar', (WidgetTester tester) async {
        await pumpRoute(tester, devices: [createRecentDevice()]);

        expect(find.byType(SoftenerMonitorAppBar), findsOneWidget);
      });
    });
  });

  group('SoftenerMonitorOverdueView', () {
    testWidgets('displays the salt level with an asterisk indicator', (WidgetTester tester) async {
      await pumpRoute(tester, devices: [createOverdueDevice()]);

      // The overdue view renders the percentage inside a RichText with TextSpan children.
      final Finder richTextFinder = find.byWidgetPredicate(
        (Widget widget) => widget is RichText && widget.text.toPlainText().contains('30%'),
      );
      expect(richTextFinder, findsOneWidget);

      // The asterisk is rendered as a separate Text widget within a WidgetSpan.
      expect(find.text('*'), findsWidgets);
    });

    testWidgets('displays the "SALT REMAINING" label', (WidgetTester tester) async {
      await pumpRoute(tester, devices: [createOverdueDevice()]);

      expect(find.text('SALT REMAINING'), findsOneWidget);
    });

    testWidgets('displays the overdue description message', (WidgetTester tester) async {
      await pumpRoute(tester, devices: [createOverdueDevice()]);

      expect(
        find.text('It has been a while since your Brine device has sent an update. It appears to be offline.'),
        findsOneWidget,
      );
    });

    testWidgets('displays the reconnect button', (WidgetTester tester) async {
      await pumpRoute(tester, devices: [createOverdueDevice()]);

      expect(find.byType(LightButton), findsOneWidget);
      expect(find.text('RECONNECT'), findsOneWidget);
    });

    testWidgets('displays the last updated timestamp', (WidgetTester tester) async {
      final BrineDevice device = createOverdueDevice();
      await pumpRoute(tester, devices: [device]);

      // The overdue view shows "Last updated: MM/DD/YYYY".
      expect(find.textContaining('Last updated:'), findsOneWidget);
      expect(find.textContaining(device.lastUpdateTime), findsOneWidget);
    });

    testWidgets('displays warning icon when salt level is 10% or below', (WidgetTester tester) async {
      await pumpRoute(tester, devices: [createOverdueDevice(saltLevel: 0.05)]);

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('does not display warning icon when salt level is above 10%', (WidgetTester tester) async {
      await pumpRoute(tester, devices: [createOverdueDevice()]);

      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    testWidgets('renders the SoftenerMonitorAppBar', (WidgetTester tester) async {
      await pumpRoute(tester, devices: [createOverdueDevice()]);

      expect(find.byType(SoftenerMonitorAppBar), findsOneWidget);
    });
  });
}
