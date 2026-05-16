import 'package:brine/components/buttons/light_button.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/errors/error_route.dart';
import 'package:brine/screens/errors/models/error_type.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tests for the [ErrorRoute] screen.
///
/// Verifies that the error screen renders the correct title, message, image, and action button for each [ErrorType].
/// Also verifies that error types without an associated action do not display a button.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/errors/error_route_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Pumps the [ErrorRoute] for the given [errorType] inside a configured [MaterialApp].
  ///
  /// Uses a taller viewport than the default 800x600 to accommodate the error screen's 256px image, title, and message
  /// text without overflow.
  Future<void> pumpErrorRoute(WidgetTester tester, {required ErrorType errorType}) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: BrineAppTheme.lightThemeData,
        darkTheme: BrineAppTheme.darkThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ErrorRoute(errorType: errorType),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ErrorRoute', () {
    group('unauthenticated error', () {
      testWidgets('displays the correct title and message', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.unauthenticated);

        expect(find.text('Authentication Error'), findsOneWidget);
        expect(find.text('Your session has expired. Please log in again.'), findsOneWidget);
      });

      testWidgets('displays a login action button', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.unauthenticated);

        expect(find.byType(LightButton), findsOneWidget);
        expect(find.text('LOGIN'), findsOneWidget);
      });
    });

    group('bluetoothPermissions error', () {
      testWidgets('displays the correct title and message', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.bluetoothPermissions);

        expect(find.text('Bluetooth Permissions Required'), findsOneWidget);
        expect(
          find.textContaining('Bluetooth permissions are required'),
          findsOneWidget,
        );
      });

      testWidgets('does not display an action button', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.bluetoothPermissions);

        expect(find.byType(LightButton), findsNothing);
      });
    });

    group('firebaseAuthCreationFailed error', () {
      testWidgets('displays the correct title and message', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.firebaseAuthCreationFailed);

        expect(find.text('We Hit a Snag Creating Your Account'), findsOneWidget);
        expect(
          find.textContaining('Something went wrong while setting up your login credentials'),
          findsOneWidget,
        );
      });

      testWidgets('displays a try again action button', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.firebaseAuthCreationFailed);

        expect(find.byType(LightButton), findsOneWidget);
        expect(find.text('TRY AGAIN'), findsOneWidget);
      });
    });

    group('userDocumentCreationFailed error', () {
      testWidgets('displays the correct title and message', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.userDocumentCreationFailed);

        expect(find.textContaining('Almost There'), findsOneWidget);
        expect(
          find.textContaining('Your account was created'),
          findsOneWidget,
        );
      });

      testWidgets('does not display an action button', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.userDocumentCreationFailed);

        expect(find.byType(LightButton), findsNothing);
      });
    });

    group('bluetoothConnection error', () {
      testWidgets('displays the correct title and message', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.bluetoothConnection);

        expect(find.text('Bluetooth Connection Failed'), findsOneWidget);
        expect(
          find.textContaining('We had a bit of trouble connecting'),
          findsOneWidget,
        );
      });

      testWidgets('displays a try again action button', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.bluetoothConnection);

        expect(find.byType(LightButton), findsOneWidget);
        expect(find.text('TRY AGAIN'), findsOneWidget);
      });
    });

    group('unknown error', () {
      testWidgets('displays the correct title and message', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.unknown);

        expect(find.text('Oh no!'), findsOneWidget);
        expect(
          find.textContaining('mysterious glitch'),
          findsOneWidget,
        );
      });

      testWidgets('does not display an action button', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.unknown);

        expect(find.byType(LightButton), findsNothing);
      });
    });

    group('layout structure', () {
      testWidgets('renders a Scaffold with the primary color background', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.unknown);

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('displays an error image', (WidgetTester tester) async {
        await pumpErrorRoute(tester, errorType: ErrorType.unknown);

        expect(find.byType(Image), findsOneWidget);
      });
    });
  });
}
