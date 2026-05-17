import 'package:brine/values/regex.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [RegEx] class.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/values/regex_test.dart
/// ```
void main() {
  group('RegEx', () {
    group('authenticationFieldsCharset', () {
      test('matches alphanumeric characters', () {
        expect(RegEx.authenticationFieldsCharset.hasMatch('Hello123'), isTrue);
      });

      test('matches special characters used in passwords', () {
        expect(RegEx.authenticationFieldsCharset.hasMatch('p@ss!w0rd#'), isTrue);
      });

      test('matches underscores and spaces', () {
        expect(RegEx.authenticationFieldsCharset.hasMatch('user_name test'), isTrue);
      });

      test('matches an empty string', () {
        expect(RegEx.authenticationFieldsCharset.hasMatch(''), isTrue);
      });
    });

    group('emailAddress', () {
      test('matches a standard email address', () {
        expect(RegEx.emailAddress.hasMatch('user@example.com'), isTrue);
      });

      test('matches an email with subdomain', () {
        expect(RegEx.emailAddress.hasMatch('user@mail.example.com'), isTrue);
      });

      test('matches an email with plus addressing', () {
        expect(RegEx.emailAddress.hasMatch('user+tag@example.com'), isTrue);
      });

      test('matches an email with dots in the local part', () {
        expect(RegEx.emailAddress.hasMatch('first.last@example.com'), isTrue);
      });

      test('does not match a string without an @ symbol', () {
        expect(RegEx.emailAddress.hasMatch('userexample.com'), isFalse);
      });

      test('does not match a string without a local part', () {
        expect(RegEx.emailAddress.hasMatch('@example.com'), isFalse);
      });

      test('does not match an empty string', () {
        expect(RegEx.emailAddress.hasMatch(''), isFalse);
      });
    });
  });
}
