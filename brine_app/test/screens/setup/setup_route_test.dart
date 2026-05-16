import 'package:brine/components/loaders/wave_loader.dart';
import 'package:brine/screens/errors/error_route.dart';
import 'package:brine/screens/setup/setup_route.dart';
import 'package:brine/screens/softener_monitor/softener_monitor_route.dart';
import 'package:brine/screens/welcome/welcome_route.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_user.mocks.dart';
import 'helpers/fake_auth_session.dart';
import 'helpers/fake_device_management_service.dart';
import 'helpers/pump_setup_route.dart';

/// Tests for the [SetupRoute] screen.
///
/// These tests exercise the controller's navigation logic by injecting fake dependencies through the route's
/// constructor parameters. This avoids any dependency on Firebase platform initialization.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/setup/setup_route_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SetupRoute', () {
    group('construction', () {
      test('can be instantiated with const constructor', () {
        const SetupRoute route = SetupRoute();
        expect(route, isA<SetupRoute>());
      });

      test('creates a SetupController as its state', () {
        const SetupRoute route = SetupRoute();
        final SetupController controller = route.createState() as SetupController;
        expect(controller, isA<SetupController>());
      });
    });

    group('navigation when user has no devices', () {
      testWidgets('navigates to WelcomeRoute when device list is empty', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_token');

        await pumpSetupRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          deviceManagementServiceFactory: fakeDeviceManagementServiceFactory(devices: []),
        );

        // Allow the async _performSetup to complete and navigation to settle.
        await tester.pumpAndSettle();

        expect(find.byType(WelcomeRoute), findsOneWidget);
        expect(find.byType(SetupRoute), findsNothing);
      });
    });

    group('navigation when user has devices', () {
      testWidgets('navigates to SoftenerMonitorRoute when devices exist', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_token');

        final List<BrineDevice> devices = createTestDevices(count: 2);

        await pumpSetupRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          deviceManagementServiceFactory: fakeDeviceManagementServiceFactory(devices: devices),
        );

        await tester.pumpAndSettle();

        expect(find.byType(SoftenerMonitorRoute), findsOneWidget);
        expect(find.byType(SetupRoute), findsNothing);
      });
    });

    group('navigation on authentication error', () {
      testWidgets('navigates to ErrorRoute when user is null', (WidgetTester tester) async {
        await pumpSetupRoute(
          tester,
          authSession: const FakeAuthSession(),
          deviceManagementServiceFactory: fakeDeviceManagementServiceFactory(),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ErrorRoute), findsOneWidget);
        expect(find.byType(SetupRoute), findsNothing);
      });

      testWidgets('navigates to ErrorRoute with unauthenticated type on AuthenticationException', (
        WidgetTester tester,
      ) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_token');

        await pumpSetupRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          deviceManagementServiceFactory: throwingAuthExceptionFactory(),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ErrorRoute), findsOneWidget);
        expect(find.byType(SetupRoute), findsNothing);
      });
    });

    group('navigation on generic error', () {
      testWidgets('navigates to ErrorRoute with unknown type on unexpected exception', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_token');

        await pumpSetupRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          deviceManagementServiceFactory: fakeDeviceManagementServiceFactory(
            exception: Exception('Network timeout'),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ErrorRoute), findsOneWidget);
        expect(find.byType(SetupRoute), findsNothing);
      });
    });

    group('view rendering', () {
      testWidgets('displays WaveLoader while setup is in progress', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_token');

        await pumpSetupRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          deviceManagementServiceFactory: fakeDeviceManagementServiceFactory(devices: []),
        );

        // Before the async work completes, the loading view should be visible.
        expect(find.byType(WaveLoader), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}
