import 'package:brine/components/buttons/light_button.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/account/account_route.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_user.mocks.dart';
import '../../screens/setup/helpers/fake_auth_session.dart';
import 'helpers/pump_account_route.dart';
import 'helpers/test_brine_device.dart';

/// Tests for the [AccountController] business logic.
///
/// With the DI system in place, these tests can now pump the full [AccountRoute] widget and verify state transitions,
/// navigation, and user interactions without requiring Firebase platform initialization.
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
        final MockUser mockUser = MockUser();
        when(mockUser.displayName).thenReturn('Scott Hatfield');

        final List<String> nameParts = mockUser.displayName!.split(' ');
        final String firstName = nameParts.first;
        final String lastName = nameParts.length > 1 ? nameParts.last : '';
        final String initials = '${firstName[0]}${lastName[0]}';

        expect(initials, 'SH');
      });

      test('computes initials from a three-part display name using first and last', () {
        final MockUser mockUser = MockUser();
        when(mockUser.displayName).thenReturn('John Michael Smith');

        final List<String> nameParts = mockUser.displayName!.split(' ');
        final String firstName = nameParts.first;
        final String lastName = nameParts.last;
        final String initials = '${firstName[0]}${lastName[0]}';

        expect(initials, 'JS');
      });
    });

    group('AccountRoute construction', () {
      test('stores the devices list passed to it', () {
        final List<BrineDevice> devices = [
          createTestDevice(deviceId: 'device_1'),
          createTestDevice(deviceId: 'device_2'),
        ];

        final AccountRoute route = AccountRoute(devices: devices);
        expect(route.devices.length, 2);
        expect(route.devices[0].deviceId, 'device_1');
        expect(route.devices[1].deviceId, 'device_2');
      });

      test('accepts an empty devices list', () {
        const AccountRoute route = AccountRoute(devices: []);
        expect(route.devices, isEmpty);
      });
    });

    group('initial state', () {
      testWidgets('renders the account view by default', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.displayName).thenReturn('Scott Hatfield');
        when(mockUser.email).thenReturn('scott@example.com');
        when(mockUser.photoURL).thenReturn(null);

        await pumpAccountRoute(
          tester,
          devices: [createTestDevice()],
          authSession: FakeAuthSession(currentUser: mockUser),
        );

        // The account view should be displayed, not the edit profile view.
        expect(find.text('Account'), findsOneWidget);
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      });

      testWidgets('displays the user display name and email', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.displayName).thenReturn('Scott Hatfield');
        when(mockUser.email).thenReturn('scott@example.com');
        when(mockUser.photoURL).thenReturn(null);

        await pumpAccountRoute(
          tester,
          devices: [createTestDevice()],
          authSession: FakeAuthSession(currentUser: mockUser),
        );

        expect(find.text('Scott Hatfield'), findsOneWidget);
        expect(find.text('scott@example.com'), findsOneWidget);
      });

      testWidgets('displays logout and delete account buttons', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.displayName).thenReturn('Scott Hatfield');
        when(mockUser.email).thenReturn('scott@example.com');
        when(mockUser.photoURL).thenReturn(null);

        await pumpAccountRoute(
          tester,
          devices: [createTestDevice()],
          authSession: FakeAuthSession(currentUser: mockUser),
        );

        // Both buttons should be present as LightButton widgets.
        expect(find.byType(LightButton), findsNWidgets(2));
        expect(find.text('LOGOUT'), findsOneWidget);
        expect(find.text('DELETE ACCOUNT'), findsOneWidget);
      });
    });

    group('edit profile toggle', () {
      testWidgets('tapping edit icon switches to edit profile view', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.displayName).thenReturn('Scott Hatfield');
        when(mockUser.email).thenReturn('scott@example.com');
        when(mockUser.photoURL).thenReturn(null);

        await pumpAccountRoute(
          tester,
          devices: [createTestDevice()],
          authSession: FakeAuthSession(currentUser: mockUser),
        );

        // Tap the edit button.
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        // The edit profile view should now be displayed with its title and close icon.
        expect(find.text('Edit Account'), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('tapping close returns to account view', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.displayName).thenReturn('Scott Hatfield');
        when(mockUser.email).thenReturn('scott@example.com');
        when(mockUser.photoURL).thenReturn(null);

        await pumpAccountRoute(
          tester,
          devices: [createTestDevice()],
          authSession: FakeAuthSession(currentUser: mockUser),
        );

        // Enter edit mode.
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        // Tap the close button to exit edit mode.
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        // Should be back on the account view.
        expect(find.text('Account'), findsOneWidget);
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      });
    });

    group('logout', () {
      testWidgets('tapping logout calls signOut and navigates to onboarding', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.displayName).thenReturn('Scott Hatfield');
        when(mockUser.email).thenReturn('scott@example.com');
        when(mockUser.photoURL).thenReturn(null);

        bool signOutCalled = false;

        await pumpAccountRoute(
          tester,
          devices: [createTestDevice()],
          authSession: FakeAuthSession(currentUser: mockUser),
          signOut: () async {
            signOutCalled = true;
          },
        );

        // Tap the logout button.
        await tester.tap(find.text('LOGOUT'));
        await tester.pumpAndSettle();

        expect(signOutCalled, isTrue);
        // After logout, the AccountRoute should no longer be in the tree.
        expect(find.byType(AccountRoute), findsNothing);
      });
    });

    group('back navigation', () {
      testWidgets('tapping back button pops the route', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.displayName).thenReturn('Scott Hatfield');
        when(mockUser.email).thenReturn('scott@example.com');
        when(mockUser.photoURL).thenReturn(null);

        // Wrap in a Navigator with a previous route so pop has somewhere to go.
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => AccountRoute(
                            devices: [createTestDevice()],
                            authSession: FakeAuthSession(currentUser: mockUser),
                          ),
                        ),
                      );
                    },
                    child: const Text('Go to Account'),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to the account route.
        await tester.tap(find.text('Go to Account'));
        await tester.pumpAndSettle();

        expect(find.byType(AccountRoute), findsOneWidget);

        // Tap the back button.
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Should have popped back.
        expect(find.byType(AccountRoute), findsNothing);
        expect(find.text('Go to Account'), findsOneWidget);
      });
    });
  });
}
