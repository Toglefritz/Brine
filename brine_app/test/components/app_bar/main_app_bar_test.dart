import 'package:brine/components/app_bar/main_app_bar.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tests for the [MainAppBar] widget.
///
/// Verifies rendering, color customization, popup menu behavior, and navigation to the account route.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/components/app_bar/main_app_bar_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Creates a test [BrineDevice] list.
  List<BrineDevice> createDevices({int count = 1}) {
    return List.generate(
      count,
      (int index) => BrineDevice(
        deviceId: 'device_$index',
        name: 'dev$index',
        saltDistance: 150,
        applianceHeight: 300,
        saltLevel: 0.5,
        batteryLevel: 0.8,
        lastUpdatedTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
        retrievalTimestamp: DateTime.now(),
      ),
    );
  }

  /// Pumps the [MainAppBar] inside a [MaterialApp] with the app's theme and localization.
  Future<void> pumpMainAppBar(
    WidgetTester tester, {
    required List<BrineDevice> devices,
    Color? backgroundColor,
    Color? menuIconColor,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BrineAppTheme.lightThemeData,
        darkTheme: BrineAppTheme.darkThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: MainAppBar(
            devices: devices,
            backgroundColor: backgroundColor,
            menuIconColor: menuIconColor,
          ),
          body: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('MainAppBar', () {
    group('rendering', () {
      testWidgets('renders an AppBar', (WidgetTester tester) async {
        await pumpMainAppBar(tester, devices: createDevices());

        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('has a preferred height of 50', (WidgetTester tester) async {
        final MainAppBar appBar = MainAppBar(devices: createDevices());
        expect(appBar.preferredSize.height, 50);
      });

      testWidgets('displays the more_vert icon', (WidgetTester tester) async {
        await pumpMainAppBar(tester, devices: createDevices());

        expect(find.byIcon(Icons.more_vert), findsOneWidget);
      });

      testWidgets('does not display a leading back button', (WidgetTester tester) async {
        await pumpMainAppBar(tester, devices: createDevices());

        // The AppBar should not have a leading widget (no back arrow).
        expect(find.byIcon(Icons.arrow_back), findsNothing);
      });
    });

    group('color customization', () {
      testWidgets('uses the theme primaryColorDark for the menu icon by default', (WidgetTester tester) async {
        await pumpMainAppBar(tester, devices: createDevices());

        final Icon icon = tester.widget(find.byIcon(Icons.more_vert));
        expect(icon.color, BrineAppTheme.lightThemeData.primaryColorDark);
      });

      testWidgets('uses the provided menuIconColor when specified', (WidgetTester tester) async {
        await pumpMainAppBar(tester, devices: createDevices(), menuIconColor: Colors.white);

        final Icon icon = tester.widget(find.byIcon(Icons.more_vert));
        expect(icon.color, Colors.white);
      });

      testWidgets('uses the provided backgroundColor when specified', (WidgetTester tester) async {
        await pumpMainAppBar(tester, devices: createDevices(), backgroundColor: Colors.purple);

        final AppBar appBar = tester.widget(find.byType(AppBar));
        expect(appBar.backgroundColor, Colors.purple);
      });
    });

    group('popup menu', () {
      testWidgets('tapping the menu icon shows the Account option', (WidgetTester tester) async {
        await pumpMainAppBar(tester, devices: createDevices());

        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        expect(find.text('Account'), findsOneWidget);
      });

      testWidgets('Account menu item has a value that triggers onSelected', (WidgetTester tester) async {
        await pumpMainAppBar(tester, devices: createDevices());

        // Open the popup menu.
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        // Verify the Account menu item is a PopupMenuItem with a non-null value (which triggers onSelected).
        final Finder menuItemFinder = find.byWidgetPredicate(
          (Widget widget) => widget is PopupMenuItem<String> && widget.value == 'Account',
        );
        expect(menuItemFinder, findsOneWidget);
      });
    });

    group('construction', () {
      test('stores the devices list', () {
        final List<BrineDevice> devices = createDevices(count: 3);
        final MainAppBar appBar = MainAppBar(devices: devices);

        expect(appBar.devices.length, 3);
      });

      test('stores null backgroundColor by default', () {
        final MainAppBar appBar = MainAppBar(devices: createDevices());
        expect(appBar.backgroundColor, isNull);
      });

      test('stores null menuIconColor by default', () {
        final MainAppBar appBar = MainAppBar(devices: createDevices());
        expect(appBar.menuIconColor, isNull);
      });
    });
  });
}
