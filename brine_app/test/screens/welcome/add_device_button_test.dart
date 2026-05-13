import 'package:brine/screens/welcome/components/add_device_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [AddDeviceButton] widget.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/welcome/add_device_button_test.dart
/// ```
void main() {
  /// Helper to pump the [AddDeviceButton] inside a minimal widget tree.
  Future<void> pumpAddDeviceButton(
    WidgetTester tester, {
    required VoidCallback onPressed,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          primaryColorLight: Colors.white,
          primaryColorDark: const Color(0xFF212121),
        ),
        home: Scaffold(
          body: Center(
            child: AddDeviceButton(onPressed: onPressed),
          ),
        ),
      ),
    );
  }

  group('AddDeviceButton', () {
    testWidgets('renders an ElevatedButton with a "+" icon', (tester) async {
      await pumpAddDeviceButton(tester, onPressed: () {});

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapCount = 0;

      await pumpAddDeviceButton(tester, onPressed: () => tapCount++);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(tapCount, 1);
    });

    testWidgets('has a circular shape', (tester) async {
      await pumpAddDeviceButton(tester, onPressed: () {});

      final ElevatedButton button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      // Resolve the shape from the button's style.
      final ButtonStyle? style = button.style;
      expect(style, isNotNull);

      final WidgetStateProperty<OutlinedBorder?>? shapeProp = style!.shape;
      expect(shapeProp, isNotNull);

      final OutlinedBorder? shape = shapeProp!.resolve(<WidgetState>{});
      expect(shape, isA<CircleBorder>());
    });

    testWidgets('has a border with width 3', (tester) async {
      await pumpAddDeviceButton(tester, onPressed: () {});

      final ElevatedButton button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final ButtonStyle? style = button.style;
      final WidgetStateProperty<BorderSide?>? sideProp = style!.side;
      expect(sideProp, isNotNull);

      final BorderSide? side = sideProp!.resolve(<WidgetState>{});
      expect(side, isNotNull);
      expect(side!.width, 3);
    });

    testWidgets('icon has size 64', (tester) async {
      await pumpAddDeviceButton(tester, onPressed: () {});

      final Icon icon = tester.widget<Icon>(find.byIcon(Icons.add));
      expect(icon.size, 64);
    });
  });
}
