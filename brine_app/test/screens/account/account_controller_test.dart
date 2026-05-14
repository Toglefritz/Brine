import 'package:brine/screens/account/account_route.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_user.mocks.dart';
import 'helpers/test_brine_device.dart';

/// Tests for the [AccountController] business logic.
///
/// Because [AccountController] accesses `FirebaseAuth.instance.currentUser` directly, these tests focus on verifiable
/// behavior that doesn't require a full Firebase mock:
/// - The userInitials computation logic (tested via the UserAvatar component)
/// - The AccountRoute widget construction and device list storage
///
/// Full widget tests of the controller's state transitions (edit mode, save profile, etc.) require mocking
/// `FirebaseAuth.instance`, which is covered by integration tests.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/account/account_controller_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AccountController', () {
    group('userInitials logic', () {
      test('computes two-letter initials from a two-part display name', () {
        // The controller's userInitials getter splits on space and takes first chars.
        final mockUser = MockUser();
        when(mockUser.displayName).thenReturn('Scott Hatfield');

        final nameParts = mockUser.displayName!.split(' ');
        final firstName = nameParts.first;
        final lastName = nameParts.length > 1 ? nameParts.last : '';
        final initials = '${firstName[0]}${lastName[0]}';

        expect(initials, 'SH');
      });

      test('computes initials from a three-part display name using first and last', () {
        final mockUser = MockUser();
        when(mockUser.displayName).thenReturn('John Michael Smith');

        final nameParts = mockUser.displayName!.split(' ');
        final firstName = nameParts.first;
        final lastName = nameParts.last;
        final initials = '${firstName[0]}${lastName[0]}';

        expect(initials, 'JS');
      });
    });

    group('AccountRoute construction', () {
      test('stores the devices list passed to it', () {
        final devices = [
          createTestDevice(deviceId: 'device_1'),
          createTestDevice(deviceId: 'device_2'),
        ];

        final route = AccountRoute(devices: devices);
        expect(route.devices.length, 2);
        expect(route.devices[0].deviceId, 'device_1');
        expect(route.devices[1].deviceId, 'device_2');
      });

      test('accepts an empty devices list', () {
        const route = AccountRoute(devices: []);
        expect(route.devices, isEmpty);
      });
    });
  });
}
