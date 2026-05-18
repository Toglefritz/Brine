import 'package:brine/services/authentication/authentication_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_user.mocks.dart';

/// Tests for [AuthenticationService].
///
/// Most methods on this service interact directly with Firebase Auth and Google Sign-In platform APIs that cannot be
/// exercised in a unit test environment. Those methods are excluded from coverage via `// coverage:ignore-start` and
/// `// coverage:ignore-end` markers in the source.
///
/// This file tests the constructor and configuration surface that can be verified without Firebase initialization.
///
/// Run with:
/// ```sh
/// flutter test test/services/authentication/authentication_service_test.dart
/// ```
void main() {
  group('AuthenticationService', () {
    group('constructor', () {
      test('should store the provided user', () {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        final AuthenticationService service = AuthenticationService(user: mockUser);

        expect(service.user.uid, 'test_uid');
      });
    });

    group('baseUrl', () {
      test('should use the emulator URL in debug mode', () {
        // In test environments, kDebugMode is true, so baseUrl should point to the local emulator.
        expect(AuthenticationService.baseUrl, contains('5001'));
      });
    });
  });
}
