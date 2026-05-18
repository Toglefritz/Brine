import 'package:brine/services/push_notifications/push_notifications_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_user.mocks.dart';

/// Tests for the [PushNotificationsService] class.
///
/// The `registerFcmToken` method accesses `FirebaseMessaging.instance.getToken()` and
/// `FirebaseAuth.instance.currentUser?.getIdToken()` directly (platform singletons), which prevents full unit testing
/// without platform-level mocking. These tests verify the service's construction and document the limitation.
///
/// Full testing of `registerFcmToken` requires either:
/// - Injecting `FirebaseMessaging` and using the `user` field for the ID token (instead of the Auth singleton)
/// - Using `firebase_messaging_platform_interface` to set a fake platform
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/services/push_notifications/push_notifications_service_test.dart
/// ```
void main() {
  group('PushNotificationsService', () {
    group('construction', () {
      test('stores the provided user', () {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        final PushNotificationsService service = PushNotificationsService(user: mockUser);

        expect(service.user.uid, 'test_uid');
      });
    });

    group('baseUrl', () {
      test('is configured for the Firebase emulator in debug mode', () {
        // In debug mode (which is always the case in tests), the baseUrl should point to the local emulator.
        expect(PushNotificationsService.baseUrl, contains('5001'));
        expect(PushNotificationsService.baseUrl, contains('brine-3b212'));
      });
    });
  });
}
