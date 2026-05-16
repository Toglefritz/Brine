import 'package:brine/screens/welcome/components/add_device_button.dart';
import 'package:brine/screens/welcome/welcome_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/pump_welcome_route.dart';

/// Tests for the [WelcomeController] business logic.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/welcome/welcome_controller_test.dart
/// ```
void main() {
  // Prevent Google Fonts from making network requests during tests.
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('WelcomeController', () {
    group('onAddDevicePressed', () {
      testWidgets('add device button is wired to the controller callback', (WidgetTester tester) async {
        await pumpWelcomeRoute(tester);

        // Verify the AddDeviceButton is present and tappable.
        final Finder addButton = find.byType(AddDeviceButton);
        expect(addButton, findsOneWidget);

        // Verify the button contains the expected "+" icon.
        final Finder icon = find.descendant(
          of: addButton,
          matching: find.byIcon(Icons.add),
        );
        expect(icon, findsOneWidget);

        // Verify the button is an ElevatedButton that can receive taps.
        final Finder elevatedButton = find.descendant(
          of: addButton,
          matching: find.byType(ElevatedButton),
        );
        expect(elevatedButton, findsOneWidget);

        final ElevatedButton button = tester.widget(elevatedButton);
        expect(button.onPressed, isNotNull);
      });
    });

    group('onOrderButtonPressed', () {
      testWidgets('tapping the order button does not navigate away', (WidgetTester tester) async {
        await pumpWelcomeRoute(tester);

        // Find and tap the "Get one now" button.
        final Finder orderButton = find.text('GET ONE NOW');
        expect(orderButton, findsOneWidget);

        await tester.tap(orderButton);
        await tester.pump();

        // The route should still be displayed since the handler is a no-op beyond analytics.
        expect(find.byType(WelcomeRoute), findsOneWidget);
      });

      testWidgets('order button is present and tappable', (WidgetTester tester) async {
        await pumpWelcomeRoute(tester);

        // Verify the order button exists.
        final Finder orderButton = find.text('GET ONE NOW');
        expect(orderButton, findsOneWidget);

        // Verify it is within an ElevatedButton.
        final Finder elevatedButton = find.ancestor(
          of: orderButton,
          matching: find.byType(ElevatedButton),
        );
        expect(elevatedButton, findsOneWidget);

        final ElevatedButton button = tester.widget(elevatedButton);
        expect(button.onPressed, isNotNull);
      });
    });

    group('initial state', () {
      testWidgets('WelcomeRoute renders without errors', (WidgetTester tester) async {
        await pumpWelcomeRoute(tester);

        // Verify the widget tree rendered without errors.
        expect(find.byType(WelcomeRoute), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('WelcomeRoute uses a Scaffold', (WidgetTester tester) async {
        await pumpWelcomeRoute(tester);

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}
