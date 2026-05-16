import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/account/account_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tests for the [AccountView] static dialog methods and layout structure.
///
/// Because [AccountRoute] accesses `FirebaseAuth.instance.currentUser` directly in its controller, full widget tests of
/// the route require Firebase mocking. These tests focus on the static dialog methods which can be tested
/// independently.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/account/account_view_test.dart
/// ```
// ignore_for_file: discarded_futures
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AccountView', () {
    group('showRemoveDeviceConfirmationDialog', () {
      testWidgets('displays dialog with device ID and action buttons', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      AccountView.showRemoveDeviceConfirmationDialog(
                        context: context,
                        deviceId: 'golden_swift_fox',
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the button to show the dialog.
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify the dialog is displayed with the correct content.
        expect(find.text('Remove device'), findsOneWidget);
        expect(find.textContaining('golden_swift_fox'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Remove'), findsOneWidget);
      });

      testWidgets('returns false when Cancel is tapped', (WidgetTester tester) async {
        bool? result;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      result = await AccountView.showRemoveDeviceConfirmationDialog(
                        context: context,
                        deviceId: 'test_device',
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(result, false);
      });

      testWidgets('returns true when Remove is tapped', (WidgetTester tester) async {
        bool? result;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      result = await AccountView.showRemoveDeviceConfirmationDialog(
                        context: context,
                        deviceId: 'test_device',
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Remove'));
        await tester.pumpAndSettle();

        expect(result, true);
      });
    });

    group('showDeleteAccountConfirmationDialog', () {
      testWidgets('displays dialog with confirmation message and action buttons', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      AccountView.showDeleteAccountConfirmationDialog(context: context);
                    },
                    child: const Text('Show Dialog'),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Delete Account'), findsOneWidget);
        expect(find.text('Are you sure you want to delete your account?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('returns false when Cancel is tapped', (WidgetTester tester) async {
        bool? result;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      result = await AccountView.showDeleteAccountConfirmationDialog(context: context);
                    },
                    child: const Text('Show Dialog'),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(result, false);
      });

      testWidgets('returns true when Delete is tapped', (WidgetTester tester) async {
        bool? result;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      result = await AccountView.showDeleteAccountConfirmationDialog(context: context);
                    },
                    child: const Text('Show Dialog'),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(result, true);
      });
    });

    group('EditProfileView.showEmailChangeConfirmationDialog', () {
      testWidgets('displays dialog with new email and OK button', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      EditProfileView.showEmailChangeConfirmationDialog(
                        context: context,
                        newEmail: 'newemail@example.com',
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Confirmation required'), findsOneWidget);
        expect(find.textContaining('newemail@example.com'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);
      });

      testWidgets('dismisses when OK is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      EditProfileView.showEmailChangeConfirmationDialog(
                        context: context,
                        newEmail: 'test@test.com',
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Dialog should be visible.
        expect(find.text('Confirmation required'), findsOneWidget);

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Dialog should be dismissed.
        expect(find.text('Confirmation required'), findsNothing);
      });
    });
  });
}
