import 'package:brine/services/analytics/analytics.dart';
import 'package:brine/services/authentication/models/auth_methods.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [Analytics] class.
///
/// In debug mode (which is always the case in tests), the Analytics methods print debug messages but do not call
/// Firebase Analytics. These tests verify that each method executes without error and produces the expected debug
/// output.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/services/analytics/analytics_test.dart
/// ```
void main() {
  group('Analytics', () {
    group('trackPageView', () {
      test('executes without error', () {
        expect(() => Analytics.trackPageView('test_page'), returnsNormally);
      });

      test('prints the page name', () {
        final List<String> logs = <String>[];
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) logs.add(message);
        };

        Analytics.trackPageView('home_screen');

        expect(logs, contains('Analytics trackPageView: home_screen'));

        // Restore default debugPrint.
        debugPrint = debugPrintThrottled;
      });
    });

    group('trackSignUp', () {
      test('executes without error', () {
        expect(() => Analytics.trackSignUp(AuthMethod.basicAuth), returnsNormally);
      });

      test('prints the sign-up event', () {
        final List<String> logs = <String>[];
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) logs.add(message);
        };

        Analytics.trackSignUp(AuthMethod.google);

        expect(logs, contains('Analytics trackSignUp'));

        debugPrint = debugPrintThrottled;
      });
    });

    group('trackLogin', () {
      test('executes without error', () {
        expect(() => Analytics.trackLogin(), returnsNormally);
      });

      test('prints the login event', () {
        final List<String> logs = <String>[];
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) logs.add(message);
        };

        Analytics.trackLogin();

        expect(logs, contains('Analytics trackLogin'));

        debugPrint = debugPrintThrottled;
      });
    });

    group('trackLogout', () {
      test('executes without error', () {
        expect(() => Analytics.trackLogout(), returnsNormally);
      });

      test('prints the logout event', () {
        final List<String> logs = <String>[];
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) logs.add(message);
        };

        Analytics.trackLogout();

        expect(logs, contains('Analytics trackLogout'));

        debugPrint = debugPrintThrottled;
      });
    });

    group('trackEvent', () {
      test('executes without error', () {
        expect(
          () => Analytics.trackEvent(eventName: 'button_tap'),
          returnsNormally,
        );
      });

      test('executes with parameters without error', () {
        expect(
          () => Analytics.trackEvent(
            eventName: 'purchase',
            parameters: {'item': 'widget', 'price': 9.99},
          ),
          returnsNormally,
        );
      });

      test('prints the event name and parameters', () {
        final List<String> logs = <String>[];
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) logs.add(message);
        };

        Analytics.trackEvent(
          eventName: 'device_added',
          parameters: {'device_id': 'abc123'},
        );

        expect(logs.any((String log) => log.contains('device_added')), isTrue);
        expect(logs.any((String log) => log.contains('abc123')), isTrue);

        debugPrint = debugPrintThrottled;
      });

      test('prints null parameters when none are provided', () {
        final List<String> logs = <String>[];
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) logs.add(message);
        };

        Analytics.trackEvent(eventName: 'simple_event');

        expect(logs, contains('Analytics trackEvent: simple_event, null'));

        debugPrint = debugPrintThrottled;
      });
    });
  });
}
