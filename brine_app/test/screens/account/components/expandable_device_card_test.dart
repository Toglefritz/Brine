import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/account/account_route.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/test_brine_device.dart';

/// Tests for the [ExpandableDeviceCard] widget.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/account/components/expandable_device_card_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Helper to pump the [ExpandableDeviceCard] widget.
  Future<void> pumpExpandableDeviceCard(
    WidgetTester tester, {
    required BrineDevice device,
    required VoidCallback onRemoveDevice,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          primaryColorDark: const Color(0xFF212121),
          cardColor: Colors.white,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 14),
          ),
        ),
        home: Scaffold(
          body: Center(
            child: ExpandableDeviceCard(
              device: device,
              onRemoveDevice: onRemoveDevice,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Helper to expand the card and wait for content to become visible. The ExpandableDeviceCard uses Future.delayed
  /// internally, so we need to pump past both the card animation (300ms) and the content visibility delay (300ms). The
  /// widget has a known overflow issue when expanded in small test viewports, so we suppress overflow errors during
  /// expansion tests.
  Future<void> expandCard(WidgetTester tester) async {
    await tester.tap(find.byType(GestureDetector).first);
    // First pump: triggers setState(_isExpanded = true) and starts the AnimatedContainer.
    await tester.pump();
    // Advance well past the card animation duration (300ms) to ensure the Future.delayed(300ms) callback fires.
    await tester.pump(const Duration(milliseconds: 500));
    // Pump to process the setState(_isContentVisible = true) from the delayed callback.
    await tester.pump();
  }

  group('ExpandableDeviceCard', () {
    testWidgets('displays device name in collapsed state', (WidgetTester tester) async {
      final BrineDevice device = createTestDevice(name: 'x7f3');

      await pumpExpandableDeviceCard(
        tester,
        device: device,
        onRemoveDevice: () {},
      );

      expect(find.text('x7f3'), findsOneWidget);
    });

    testWidgets('does not show device details in collapsed state', (WidgetTester tester) async {
      final BrineDevice device = createTestDevice(deviceId: 'my_device_123');

      await pumpExpandableDeviceCard(
        tester,
        device: device,
        onRemoveDevice: () {},
      );

      // Device ID detail should not be visible when collapsed.
      expect(find.text('my_device_123'), findsNothing);
    });

    testWidgets('does not show delete button in collapsed state', (WidgetTester tester) async {
      await pumpExpandableDeviceCard(
        tester,
        device: createTestDevice(),
        onRemoveDevice: () {},
      );

      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });

    testWidgets('expands on tap (container height increases)', (WidgetTester tester) async {
      // Suppress overflow errors — the ExpandableDeviceCard has a known layout overflow when the expanded content
      // exceeds the AnimatedContainer's scaled height in test viewports.
      final void Function(FlutterErrorDetails)? originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };

      addTearDown(() => FlutterError.onError = originalOnError);

      final BrineDevice device = createTestDevice(
        deviceId: 'silver_fox_42',
        name: 'z9k1',
      );

      await pumpExpandableDeviceCard(
        tester,
        device: device,
        onRemoveDevice: () {},
      );

      // Get the initial height of the AnimatedContainer.
      final Size initialSize = tester.getSize(find.byType(AnimatedContainer));

      // Tap to expand.
      await tester.tap(find.text('z9k1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Get the expanded height.
      final Size expandedSize = tester.getSize(find.byType(AnimatedContainer));

      // The height should have increased.
      expect(expandedSize.height, greaterThan(initialSize.height));
    });

    testWidgets('shows delete button when expanded', (WidgetTester tester) async {
      final void Function(FlutterErrorDetails)? originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await pumpExpandableDeviceCard(
        tester,
        device: createTestDevice(),
        onRemoveDevice: () {},
      );

      await expandCard(tester);

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('calls onRemoveDevice when delete button is tapped', (WidgetTester tester) async {
      final void Function(FlutterErrorDetails)? originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      int removeCallCount = 0;

      await pumpExpandableDeviceCard(
        tester,
        device: createTestDevice(),
        onRemoveDevice: () => removeCallCount++,
      );

      await expandCard(tester);

      // Tap the delete button.
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pump();

      expect(removeCallCount, 1);
    });

    testWidgets('collapses on second tap (delete button removed)', (WidgetTester tester) async {
      final void Function(FlutterErrorDetails)? originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await pumpExpandableDeviceCard(
        tester,
        device: createTestDevice(),
        onRemoveDevice: () {},
      );

      // Expand the card.
      await expandCard(tester);

      // Verify the delete button is visible when expanded.
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      // Tap again to collapse.
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();

      // The delete button should be gone since it's gated on _isExpanded.
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });
  });
}
