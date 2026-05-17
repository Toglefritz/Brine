import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/softener_monitor/softener_monitor_route.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/create_test_devices.dart';

/// Tests for the [SoftenerMonitorAppBar] widget.
///
/// Verifies the device selector menu behavior (shown only when multiple devices exist), the overflow menu with the
/// account option, and the display of the currently selected device name.
///
/// Because the [SoftenerMonitorView] contains a [WaveProgressIndicator] with a repeating animation, these tests use
/// `tester.pump()` instead of `tester.pumpAndSettle()` for the initial render. The wave animation never completes, so
/// `pumpAndSettle` would time out.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/softener_monitor/components/softener_monitor_app_bar_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Pumps the [SoftenerMonitorRoute] with the given devices inside a configured [MaterialApp].
  ///
  /// Uses `pump()` with a short duration rather than `pumpAndSettle()` because the wave animation in the view runs
  /// indefinitely.
  Future<void> pumpSoftenerMonitorRoute(
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

    // Pump a single frame to allow initState and the first build to complete.
    await tester.pump();
  }

  group('SoftenerMonitorAppBar', () {
    group('overflow menu', () {
      testWidgets('displays the more_vert icon button', (WidgetTester tester) async {
        await pumpSoftenerMonitorRoute(tester, devices: createTestDevices());

        expect(find.byIcon(Icons.more_vert), findsOneWidget);
      });

      testWidgets('tapping more_vert shows the Account menu item', (WidgetTester tester) async {
        await pumpSoftenerMonitorRoute(tester, devices: createTestDevices());

        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pump();
        // Allow the popup menu animation to progress.
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Account'), findsOneWidget);
      });
    });

    group('device selector with single device', () {
      testWidgets('does not display the device selector when only one device exists', (WidgetTester tester) async {
        await pumpSoftenerMonitorRoute(tester, devices: createTestDevices());

        // With a single device, the MenuAnchor should not be rendered.
        expect(find.byType(MenuAnchor), findsNothing);
      });
    });

    group('device selector with multiple devices', () {
      testWidgets('displays the device selector when multiple devices exist', (WidgetTester tester) async {
        await pumpSoftenerMonitorRoute(tester, devices: createTestDevices(count: 2));

        expect(find.byType(MenuAnchor), findsOneWidget);
      });

      testWidgets('displays the selected device name in uppercase', (WidgetTester tester) async {
        final List<BrineDevice> devices = createTestDevices(count: 2);
        await pumpSoftenerMonitorRoute(tester, devices: devices);

        // The first device is selected by default. The device selector uses RichText with TextSpan children, so we
        // search for the device name within RichText widgets.
        final Finder richTextFinder = find.byWidgetPredicate(
          (Widget widget) => widget is RichText && widget.text.toPlainText().contains(devices.first.name.toUpperCase()),
        );
        expect(richTextFinder, findsOneWidget);
      });

      testWidgets('tapping the device selector opens the menu with all device names', (WidgetTester tester) async {
        final List<BrineDevice> devices = createTestDevices(count: 3);
        await pumpSoftenerMonitorRoute(tester, devices: devices);

        // Tap the device selector button (the TextButton inside the MenuAnchor).
        await tester.tap(find.byType(TextButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // All device names should appear in the menu.
        for (final BrineDevice device in devices) {
          expect(find.text(device.name.toUpperCase()), findsWidgets);
        }
      });

      testWidgets('device selector menu items are tappable', (WidgetTester tester) async {
        final List<BrineDevice> devices = createTestDevices(count: 2);
        await pumpSoftenerMonitorRoute(tester, devices: devices);

        // Open the device selector menu.
        await tester.tap(find.byType(TextButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify the second device menu item exists and is a MenuItemButton (tappable).
        final Finder menuItem = find.ancestor(
          of: find.text(devices[1].name.toUpperCase()),
          matching: find.byType(MenuItemButton),
        );
        expect(menuItem, findsOneWidget);
      });
    });
  });
}
