import 'package:brine/screens/softener_monitor/softener_monitor_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [WaveProgressIndicator] widget and [WavePainter].
///
/// Because the wave animation runs indefinitely via `AnimationController.repeat()`, these tests use `tester.pump()`
/// with explicit durations rather than `tester.pumpAndSettle()`.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/softener_monitor/components/wave_progress_indicator_test.dart
/// ```
void main() {
  group('WaveProgressIndicator', () {
    group('rendering', () {
      testWidgets('renders a CustomPaint widget', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 300,
                child: WaveProgressIndicator(
                  progressPercent: 0.5,
                  fillColor: Colors.blue,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('uses a WavePainter as the custom painter', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 300,
                child: WaveProgressIndicator(
                  progressPercent: 0.7,
                  fillColor: Colors.green,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final Finder customPaintFinder = find.byWidgetPredicate(
          (Widget widget) => widget is CustomPaint && widget.painter is WavePainter,
        );
        expect(customPaintFinder, findsOneWidget);
      });

      testWidgets('passes the correct fill color to the painter', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 300,
                child: WaveProgressIndicator(
                  progressPercent: 0.5,
                  fillColor: Colors.red,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final CustomPaint customPaint = tester.widget(
          find.byWidgetPredicate(
            (Widget widget) => widget is CustomPaint && widget.painter is WavePainter,
          ),
        );
        final WavePainter painter = customPaint.painter! as WavePainter;
        expect(painter.fillColor, Colors.red);
      });

      testWidgets('painter receives the initial progress percent', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 300,
                child: WaveProgressIndicator(
                  progressPercent: 0.65,
                  fillColor: Colors.blue,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final CustomPaint customPaint = tester.widget(
          find.byWidgetPredicate(
            (Widget widget) => widget is CustomPaint && widget.painter is WavePainter,
          ),
        );
        final WavePainter painter = customPaint.painter! as WavePainter;
        expect(painter.progressPercent, 0.65);
      });
    });

    group('animation', () {
      testWidgets('wave animation value changes over time', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 300,
                child: WaveProgressIndicator(
                  progressPercent: 0.5,
                  fillColor: Colors.blue,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Capture the initial wave animation value.
        CustomPaint customPaint = tester.widget(
          find.byWidgetPredicate(
            (Widget widget) => widget is CustomPaint && widget.painter is WavePainter,
          ),
        );
        WavePainter painter = customPaint.painter! as WavePainter;
        final double initialWaveValue = painter.waveAnimationValue;

        // Advance time by 1 second (half the 2-second wave cycle).
        await tester.pump(const Duration(seconds: 1));

        // The wave animation value should have changed.
        customPaint = tester.widget(
          find.byWidgetPredicate(
            (Widget widget) => widget is CustomPaint && widget.painter is WavePainter,
          ),
        );
        painter = customPaint.painter! as WavePainter;
        expect(painter.waveAnimationValue, isNot(equals(initialWaveValue)));
      });

      testWidgets('progress percent remains stable when widget is not updated', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 300,
                child: WaveProgressIndicator(
                  progressPercent: 0.4,
                  fillColor: Colors.blue,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Advance time without changing the widget.
        await tester.pump(const Duration(seconds: 1));

        final CustomPaint customPaint = tester.widget(
          find.byWidgetPredicate(
            (Widget widget) => widget is CustomPaint && widget.painter is WavePainter,
          ),
        );
        final WavePainter painter = customPaint.painter! as WavePainter;

        // The progress percent should remain at the initial value since no update occurred.
        expect(painter.progressPercent, 0.4);
      });
    });
  });

  group('WavePainter', () {
    test('shouldRepaint always returns true', () {
      final WavePainter painter = WavePainter(
        progressPercent: 0.5,
        waveAnimationValue: 0.0,
        fillColor: Colors.blue,
      );

      final WavePainter otherPainter = WavePainter(
        progressPercent: 0.5,
        waveAnimationValue: 0.0,
        fillColor: Colors.blue,
      );

      // shouldRepaint returns true unconditionally because the wave animation is continuous.
      expect(painter.shouldRepaint(otherPainter), isTrue);
    });

    test('stores the provided progress percent', () {
      final WavePainter painter = WavePainter(
        progressPercent: 0.75,
        waveAnimationValue: 0.3,
        fillColor: Colors.green,
      );

      expect(painter.progressPercent, 0.75);
      expect(painter.waveAnimationValue, 0.3);
      expect(painter.fillColor, Colors.green);
    });
  });
}
