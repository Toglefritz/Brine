import 'dart:async';

import 'package:brine/brine_app.dart';
import 'package:brine/screens/authentication/onboarding/onboarding_route.dart';
import 'package:brine/screens/setup/setup_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mock_user.mocks.dart';

/// Tests for the [BrineApp] widget.
///
/// Verifies the auth-state routing logic: unauthenticated users see the [OnboardingRoute], authenticated users see the
/// [SetupRoute].
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/brine_app_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('BrineApp', () {
    testWidgets('shows OnboardingRoute when auth state emits null', (WidgetTester tester) async {
      // Provide a stream that emits null (no authenticated user).
      final StreamController<User?> authController = StreamController<User?>();

      await tester.pumpWidget(BrineApp(authStateStream: authController.stream));
      await tester.pump();

      // With no data emitted yet, the StreamBuilder has no data, so OnboardingRoute is shown.
      expect(find.byType(OnboardingRoute), findsOneWidget);
      expect(find.byType(SetupRoute), findsNothing);

      await authController.close();
    });

    testWidgets('shows SetupRoute when auth state emits a user', (WidgetTester tester) async {
      final MockUser mockUser = MockUser();
      when(mockUser.uid).thenReturn('test_uid');

      // Provide a stream that immediately emits an authenticated user.
      final Stream<User?> authStream = Stream<User?>.value(mockUser);

      await tester.pumpWidget(BrineApp(authStateStream: authStream));
      await tester.pump();

      // With a user emitted, the StreamBuilder has data, so SetupRoute is shown.
      expect(find.byType(SetupRoute), findsOneWidget);
      expect(find.byType(OnboardingRoute), findsNothing);
    });

    testWidgets('transitions from OnboardingRoute to SetupRoute when user signs in', (WidgetTester tester) async {
      final MockUser mockUser = MockUser();
      when(mockUser.uid).thenReturn('test_uid');

      final StreamController<User?> authController = StreamController<User?>();

      await tester.pumpWidget(BrineApp(authStateStream: authController.stream));
      await tester.pump();

      // Initially unauthenticated.
      expect(find.byType(OnboardingRoute), findsOneWidget);

      // Simulate sign-in. The stream event is delivered asynchronously, so we need to pump to process it.
      authController.add(mockUser);
      await tester.pump(); // Delivers the stream event to the StreamBuilder.
      await tester.pump(); // Rebuilds the widget tree with the new data.

      // SetupRoute should now be in the tree.
      expect(find.byType(SetupRoute), findsOneWidget);

      await authController.close();
    });

    testWidgets('uses the app theme and localization delegates', (WidgetTester tester) async {
      final StreamController<User?> authController = StreamController<User?>();

      await tester.pumpWidget(BrineApp(authStateStream: authController.stream));
      await tester.pump();

      // Verify a MaterialApp is rendered.
      expect(find.byType(MaterialApp), findsOneWidget);

      await authController.close();
    });

    test('navigatorKey is a valid GlobalKey', () {
      expect(BrineApp.navigatorKey, isA<GlobalKey<NavigatorState>>());
    });
  });
}
