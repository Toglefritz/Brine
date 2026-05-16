import 'package:brine/screens/account/account_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/mock_user.mocks.dart';

/// Tests for the [UserAvatar] widget.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/account/components/user_avatar_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('UserAvatar', () {
    testWidgets('displays initials when user has no photo URL', (WidgetTester tester) async {
      final MockUser mockUser = MockUser();
      when(mockUser.photoURL).thenReturn(null);
      when(mockUser.displayName).thenReturn('John Doe');
      when(mockUser.email).thenReturn('john@example.com');

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: const Color(0xFFEDA200),
            textTheme: const TextTheme(
              displayMedium: TextStyle(fontSize: 45),
            ),
          ),
          home: Scaffold(
            body: UserAvatar(user: mockUser),
          ),
        ),
      );

      // Should display initials "JD" from "John Doe".
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('displays single initial when user has only first name', (WidgetTester tester) async {
      final MockUser mockUser = MockUser();
      when(mockUser.photoURL).thenReturn(null);
      when(mockUser.displayName).thenReturn('Alice');
      when(mockUser.email).thenReturn('alice@example.com');

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: const Color(0xFFEDA200),
            textTheme: const TextTheme(
              displayMedium: TextStyle(fontSize: 45),
            ),
          ),
          home: Scaffold(
            body: UserAvatar(user: mockUser),
          ),
        ),
      );

      // Should display single initial "A" from "Alice".
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('falls back to email when display name is null', (WidgetTester tester) async {
      final MockUser mockUser = MockUser();
      when(mockUser.photoURL).thenReturn(null);
      when(mockUser.displayName).thenReturn(null);
      when(mockUser.email).thenReturn('bob@example.com');

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: const Color(0xFFEDA200),
            textTheme: const TextTheme(
              displayMedium: TextStyle(fontSize: 45),
            ),
          ),
          home: Scaffold(
            body: UserAvatar(user: mockUser),
          ),
        ),
      );

      // Should display "B" from "bob@example.com" (single word, first char).
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('displays empty string when user is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: const Color(0xFFEDA200),
            textTheme: const TextTheme(
              displayMedium: TextStyle(fontSize: 45),
            ),
          ),
          home: const Scaffold(
            body: UserAvatar(user: null),
          ),
        ),
      );

      // Should display empty text (no initials).
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('displays CircleAvatar when user has a photo URL', (WidgetTester tester) async {
      final MockUser mockUser = MockUser();
      when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
      when(mockUser.displayName).thenReturn('Jane Smith');
      when(mockUser.email).thenReturn('jane@example.com');

      // Suppress network image errors — in the test environment, all HTTP requests return 400.
      final void Function(FlutterErrorDetails)? originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('NetworkImageLoadException')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: const Color(0xFFEDA200),
            textTheme: const TextTheme(
              displayMedium: TextStyle(fontSize: 45),
            ),
          ),
          home: Scaffold(
            body: UserAvatar(user: mockUser),
          ),
        ),
      );

      // Allow the image load attempt to complete (it will fail with 400 in tests).
      await tester.pump();

      // Should display a CircleAvatar (the widget is present even though the image fails to load).
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('respects custom radius', (WidgetTester tester) async {
      final MockUser mockUser = MockUser();
      when(mockUser.photoURL).thenReturn(null);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: const Color(0xFFEDA200),
            textTheme: const TextTheme(
              displayMedium: TextStyle(fontSize: 45),
            ),
          ),
          home: Scaffold(
            body: UserAvatar(user: mockUser, radius: 75),
          ),
        ),
      );

      // The container should have width and height of radius * 2 = 150.
      final Container container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, 150);
      expect(container.constraints?.maxHeight, 150);
    });
  });
}
