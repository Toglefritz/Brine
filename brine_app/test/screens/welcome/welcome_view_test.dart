import 'package:brine/components/app_bar/main_app_bar.dart';
import 'package:brine/components/buttons/light_button.dart';
import 'package:brine/screens/welcome/components/add_device_button.dart';
import 'package:brine/screens/welcome/welcome_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/pump_welcome_route.dart';

/// Tests for the [WelcomeView] rendering across various screen sizes.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/welcome/welcome_view_test.dart
/// ```
void main() {
  // Prevent Google Fonts from making network requests during tests.
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// A map of device names to their screen sizes, representing the range of mobile and desktop platforms supported by
  /// this app.
  final Map<String, Size> screenSizes = {
    'iPhone SE': const Size(375, 667),
    'iPhone 15 Pro': const Size(393, 852),
    'iPhone 15 Pro Max': const Size(430, 932),
    'Pixel 7': const Size(412, 915),
    'iPad Air': const Size(820, 1180),
    'iPad Pro 12.9"': const Size(1024, 1366),
    'Desktop 1080p': const Size(1920, 1080),
    'Desktop 1440p': const Size(2560, 1440),
  };

  group('WelcomeView renders correctly', () {
    for (final entry in screenSizes.entries) {
      testWidgets('renders without errors on ${entry.key} (${entry.value.width}x${entry.value.height})', (
        tester,
      ) async {
        // Set the simulated screen size.
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await pumpWelcomeRoute(tester);

        // Verify the route rendered without errors.
        expect(find.byType(WelcomeRoute), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('WelcomeView displays expected widgets', () {
    testWidgets('displays the MainAppBar', (tester) async {
      await pumpWelcomeRoute(tester);

      expect(find.byType(MainAppBar), findsOneWidget);
    });

    testWidgets('displays the "Add a device" heading text', (tester) async {
      await pumpWelcomeRoute(tester);

      expect(find.text('Add a device'), findsOneWidget);
    });

    testWidgets('displays the invitation text', (tester) async {
      await pumpWelcomeRoute(tester);

      expect(
        find.text('Get started by linking your Brine device to the app.'),
        findsOneWidget,
      );
    });

    testWidgets('displays the AddDeviceButton', (tester) async {
      await pumpWelcomeRoute(tester);

      expect(find.byType(AddDeviceButton), findsOneWidget);
    });

    testWidgets('displays the sales prompt and order button', (tester) async {
      await pumpWelcomeRoute(tester);

      expect(find.text("Don't have a Brine device?"), findsOneWidget);
      expect(find.byType(LightButton), findsOneWidget);
      expect(find.text('GET ONE NOW'), findsOneWidget);
    });
  });
}
