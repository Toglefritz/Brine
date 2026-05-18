import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [ColorLibrary] ThemeExtension.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/theme/color_library_test.dart
/// ```
void main() {
  group('ColorLibrary', () {
    group('construction', () {
      test('stores the error color', () {
        const ColorLibrary library = ColorLibrary(error: Colors.red);
        expect(library.error, Colors.red);
      });

      test('accepts a null error color', () {
        const ColorLibrary library = ColorLibrary(error: null);
        expect(library.error, isNull);
      });
    });

    group('copyWith', () {
      test('returns a new instance with the updated error color', () {
        const ColorLibrary original = ColorLibrary(error: Colors.red);
        final ColorLibrary copy = original.copyWith(error: Colors.blue);

        expect(copy.error, Colors.blue);
        expect(original.error, Colors.red);
      });

      test('preserves the error color when no override is provided', () {
        const ColorLibrary original = ColorLibrary(error: Colors.red);
        final ColorLibrary copy = original.copyWith();

        expect(copy.error, Colors.red);
      });
    });

    group('lerp', () {
      test('interpolates between two ColorLibrary instances', () {
        const ColorLibrary start = ColorLibrary(error: Colors.red);
        const ColorLibrary end = ColorLibrary(error: Colors.blue);

        final ColorLibrary mid = start.lerp(end, 0.5);

        expect(mid.error, Color.lerp(Colors.red, Colors.blue, 0.5));
      });

      test('returns this when other is not a ColorLibrary', () {
        const ColorLibrary start = ColorLibrary(error: Colors.red);

        final ColorLibrary result = start.lerp(null, 0.5);

        expect(result.error, Colors.red);
      });

      test('returns the start color at t=0', () {
        const ColorLibrary start = ColorLibrary(error: Colors.red);
        const ColorLibrary end = ColorLibrary(error: Colors.blue);

        final ColorLibrary result = start.lerp(end, 0.0);

        expect(result.error, Color.lerp(Colors.red, Colors.blue, 0.0));
      });

      test('returns the end color at t=1', () {
        const ColorLibrary start = ColorLibrary(error: Colors.red);
        const ColorLibrary end = ColorLibrary(error: Colors.blue);

        final ColorLibrary result = start.lerp(end, 1.0);

        expect(result.error, Color.lerp(Colors.red, Colors.blue, 1.0));
      });
    });
  });
}
