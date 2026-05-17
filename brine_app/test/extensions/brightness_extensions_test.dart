import 'package:brine/extensions/brightness_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [BrightnessExtensions] extension on [Brightness].
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/extensions/brightness_extensions_test.dart
/// ```
void main() {
  group('BrightnessExtensions', () {
    group('oppositeSystemOverlayStyle', () {
      test('returns dark overlay style when brightness is light', () {
        const Brightness brightness = Brightness.light;
        expect(brightness.oppositeSystemOverlayStyle(), SystemUiOverlayStyle.dark);
      });

      test('returns light overlay style when brightness is dark', () {
        const Brightness brightness = Brightness.dark;
        expect(brightness.oppositeSystemOverlayStyle(), SystemUiOverlayStyle.light);
      });
    });

    group('isDark', () {
      test('returns true when brightness is dark', () {
        const Brightness brightness = Brightness.dark;
        expect(brightness.isDark, isTrue);
      });

      test('returns false when brightness is light', () {
        const Brightness brightness = Brightness.light;
        expect(brightness.isDark, isFalse);
      });
    });
  });
}
