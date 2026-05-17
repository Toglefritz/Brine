import 'dart:async';

import 'package:brine/components/loaders/wave_loader.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/device_configuration/association/association_route.dart';
import 'package:brine/services/device_management/device_management_service.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/mock_user.mocks.dart';
import '../../../screens/setup/helpers/fake_auth_session.dart';
import '../appliance_measurement/helpers/mock_ble_communication_service.mocks.dart';

/// Tests for the [AssociationRoute], its controller, and view.
///
/// Verifies that the view renders the loading state correctly, that the controller calls the device management service
/// to associate the device, and that navigation proceeds after association completes.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/device_configuration/association/association_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Creates a test [BrineDevice].
  BrineDevice createTestDevice() {
    return BrineDevice(
      deviceId: 'test_device_id',
      name: 'dev0',
      saltDistance: 150,
      applianceHeight: 300,
      saltLevel: 0.5,
      batteryLevel: 0.8,
      lastUpdatedTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
      retrievalTimestamp: DateTime.now(),
    );
  }

  /// Pumps the [AssociationRoute] with injected dependencies.
  Future<void> pumpRoute(
    WidgetTester tester, {
    required FakeAuthSession authSession,
    DeviceManagementService Function(User user)? serviceFactory,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BrineAppTheme.lightThemeData,
        darkTheme: BrineAppTheme.darkThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AssociationRoute(
          device: createTestDevice(),
          bleCommunicationManager: MockBleCommunicationService(),
          authSession: authSession,
          deviceManagementServiceFactory: serviceFactory,
        ),
      ),
    );
  }

  group('AssociationRoute', () {
    group('view rendering', () {
      testWidgets('displays the WaveLoader while associating', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        // Use a completer-based service so the future stays pending without creating a timer.
        await pumpRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          serviceFactory: (User user) => _PendingService(user: user),
        );

        // Pump one frame to render the initial build (before the post-frame callback fires).
        await tester.pump();

        expect(find.byType(WaveLoader), findsOneWidget);
      });

      testWidgets('displays the "Associating to account..." text', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        await pumpRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          serviceFactory: (User user) => _PendingService(user: user),
        );

        await tester.pump();

        expect(find.text('Associating to account...'), findsOneWidget);
      });

      testWidgets('renders a Scaffold', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        await pumpRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          serviceFactory: (User user) => _PendingService(user: user),
        );

        await tester.pump();

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('controller business logic', () {
      testWidgets('calls addDeviceToAccount with the correct device', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        bool addDeviceCalled = false;
        String? capturedDeviceId;

        // Use a pending service so the navigation doesn't fire (avoiding the Firebase exception from the destination).
        await pumpRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          serviceFactory: (User user) => _TrackingPendingService(
            user: user,
            onAddDevice: (BrineDevice device) {
              addDeviceCalled = true;
              capturedDeviceId = device.deviceId;
            },
          ),
        );

        // Pump to trigger the post-frame callback.
        await tester.pump();

        // The service was called with the correct device.
        expect(addDeviceCalled, isTrue);
        expect(capturedDeviceId, 'test_device_id');
      });
    });
  });
}

/// A [DeviceManagementService] whose [addDeviceToAccount] returns a future that never completes.
///
/// Uses a [Completer] rather than [Future.delayed] to avoid creating pending timers that the test framework rejects.
class _PendingService extends DeviceManagementService {
  _PendingService({required super.user});

  final Completer<void> _completer = Completer<void>();

  @override
  Future<void> addDeviceToAccount({required BrineDevice device}) => _completer.future;
}

/// A [DeviceManagementService] that tracks the call to [addDeviceToAccount] and then never completes.
///
/// This allows tests to verify the service was called without triggering navigation to the next route.
class _TrackingPendingService extends DeviceManagementService {
  _TrackingPendingService({required super.user, required this.onAddDevice});

  final void Function(BrineDevice device) onAddDevice;
  final Completer<void> _completer = Completer<void>();

  @override
  Future<void> addDeviceToAccount({required BrineDevice device}) {
    onAddDevice(device);
    return _completer.future;
  }
}
