import 'dart:async';

import 'package:brine/components/loaders/wave_loader.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/device_configuration/pre_shared_key_setup/pre_shared_key_setup_route.dart';
import 'package:brine/services/device_management/device_management_service.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:brine/services/device_management/models/pre_shared_key.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/mock_user.mocks.dart';
import '../../../screens/setup/helpers/fake_auth_session.dart';
import '../appliance_measurement/helpers/mock_ble_communication_service.mocks.dart';

/// Tests for the [PreSharedKeySetupRoute], its controller, and view.
///
/// Verifies that the view renders the loading state, that the controller requests a PSK from the service, and that the
/// PSK is transferred to the BLE device.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/device_configuration/pre_shared_key_setup/pre_shared_key_setup_test.dart
/// ```
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

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

  /// Pumps the [PreSharedKeySetupRoute] with injected dependencies.
  Future<void> pumpRoute(
    WidgetTester tester, {
    required FakeAuthSession authSession,
    required MockBleCommunicationService mockBle,
    DeviceManagementService Function(User user)? serviceFactory,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BrineAppTheme.lightThemeData,
        darkTheme: BrineAppTheme.darkThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PreSharedKeySetupRoute(
          device: createTestDevice(),
          bleCommunicationManager: mockBle,
          authSession: authSession,
          deviceManagementServiceFactory: serviceFactory,
        ),
      ),
    );
  }

  group('PreSharedKeySetupRoute', () {
    group('view rendering', () {
      testWidgets('displays the WaveLoader', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          mockBle: mockBle,
          serviceFactory: (User user) => _PendingPskService(user: user),
        );

        await tester.pump();

        expect(find.byType(WaveLoader), findsOneWidget);
      });

      testWidgets('displays the "Performing security setup..." text', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          mockBle: mockBle,
          serviceFactory: (User user) => _PendingPskService(user: user),
        );

        await tester.pump();

        expect(find.text('Performing security setup...'), findsOneWidget);
      });

      testWidgets('renders a Scaffold', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          mockBle: mockBle,
          serviceFactory: (User user) => _PendingPskService(user: user),
        );

        await tester.pump();

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('controller business logic', () {
      testWidgets('calls generatePreSharedKey with the correct device ID', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        String? capturedDeviceId;
        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          mockBle: mockBle,
          serviceFactory: (User user) => _TrackingPskService(
            user: user,
            onGeneratePsk: (String deviceId) {
              capturedDeviceId = deviceId;
            },
          ),
        );

        // Pump to trigger the post-frame callback.
        await tester.pump();

        expect(capturedDeviceId, 'test_device_id');
      });

      testWidgets('writes the PSK to the BLE device after generation', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          mockBle: mockBle,
          serviceFactory: (User user) => _ImmediatePskService(user: user),
        );

        // Pump to trigger the post-frame callback and allow the async chain to complete.
        await tester.pump();
        await tester.pump();

        // Verify that writeValue was called on the BLE service (the PSK transfer command).
        verify(mockBle.writeValue(value: anyNamed('value'))).called(1);
      });

      testWidgets('registers a callback on the BLE service for the PSK response', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        final MockBleCommunicationService mockBle = MockBleCommunicationService();

        await pumpRoute(
          tester,
          authSession: FakeAuthSession(currentUser: mockUser),
          mockBle: mockBle,
          serviceFactory: (User user) => _ImmediatePskService(user: user),
        );

        await tester.pump();
        await tester.pump();

        // Verify that registerCallback was called on the BLE service.
        verify(mockBle.registerCallback(any)).called(1);
      });
    });
  });
}

/// A [DeviceManagementService] whose [generatePreSharedKey] never completes, keeping the loading state visible.
class _PendingPskService extends DeviceManagementService {
  _PendingPskService({required super.user});

  final Completer<PreSharedKey> _completer = Completer<PreSharedKey>();

  @override
  Future<PreSharedKey> generatePreSharedKey({required String deviceId}) => _completer.future;
}

/// A [DeviceManagementService] that tracks the call to [generatePreSharedKey] and then never completes.
class _TrackingPskService extends DeviceManagementService {
  _TrackingPskService({required super.user, required this.onGeneratePsk});

  final void Function(String deviceId) onGeneratePsk;
  final Completer<PreSharedKey> _completer = Completer<PreSharedKey>();

  @override
  Future<PreSharedKey> generatePreSharedKey({required String deviceId}) {
    onGeneratePsk(deviceId);
    return _completer.future;
  }
}

/// A [DeviceManagementService] that immediately returns a test PSK.
class _ImmediatePskService extends DeviceManagementService {
  _ImmediatePskService({required super.user});

  @override
  Future<PreSharedKey> generatePreSharedKey({required String deviceId}) async {
    return PreSharedKey.fromJson({'psk': 'test_psk_value_abc123'});
  }
}
