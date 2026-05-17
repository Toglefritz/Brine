import 'package:brine/components/buttons/light_button.dart';
import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/models/unit_of_measurement.dart';
import 'package:brine/screens/device_configuration/appliance_measurement/appliance_measurement_route.dart';
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
import 'helpers/mock_ble_communication_service.mocks.dart';

/// Tests for the [ApplianceMeasurementRoute], its controller, and view.
///
/// Verifies the unit conversion logic, view rendering, unit of measurement selection, and the height submission flow.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/screens/device_configuration/appliance_measurement/appliance_measurement_test.dart
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

  /// A fake [DeviceManagementService] that records calls to [updateApplianceHeight].
  late _FakeDeviceManagementService fakeService;

  /// Factory that creates the fake service and stores a reference for assertions.
  DeviceManagementService Function(User user) createFakeServiceFactory() {
    return (User user) {
      // ignore: join_return_with_assignment
      fakeService = _FakeDeviceManagementService(user: user);
      return fakeService;
    };
  }

  /// Pumps the [ApplianceMeasurementRoute] with injected dependencies.
  Future<void> pumpRoute(
    WidgetTester tester, {
    required MockUser mockUser,
    DeviceManagementService Function(User user)? serviceFactory,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BrineAppTheme.lightThemeData,
        darkTheme: BrineAppTheme.darkThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ApplianceMeasurementRoute(
          bleCommunicationManager: MockBleCommunicationService(),
          device: createTestDevice(),
          authSession: FakeAuthSession(currentUser: mockUser),
          deviceManagementServiceFactory: serviceFactory,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ApplianceMeasurementController', () {
    group('unit conversion (_convertToMillimeters)', () {
      // The conversion logic is private, but we can test it indirectly by submitting a height value with different
      // units and verifying the value passed to the service.

      testWidgets('converts inches to millimeters correctly', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_token');

        final DeviceManagementService Function(User user) factory = createFakeServiceFactory();
        await pumpRoute(tester, mockUser: mockUser, serviceFactory: factory);

        // The default unit is inches. Enter a height of 36 inches.
        await tester.enterText(find.byType(TextField), '36');
        await tester.pump();

        // Tap the save button.
        await tester.tap(find.byType(LightButton));
        await tester.pump();

        // 36 inches * 25.4 = 914.4, rounded to 914
        expect(fakeService.lastHeight, 914);
        expect(fakeService.lastDeviceId, 'test_device_id');
      });

      testWidgets('converts centimeters to millimeters correctly', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_token');

        final DeviceManagementService Function(User user) factory = createFakeServiceFactory();
        await pumpRoute(tester, mockUser: mockUser, serviceFactory: factory);

        // Change unit to centimeters.
        await tester.tap(find.byType(DropdownButton<UnitOfMeasurement>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('cm').last);
        await tester.pumpAndSettle();

        // Enter a height of 90 cm.
        await tester.enterText(find.byType(TextField), '90');
        await tester.pump();

        // Tap the save button.
        await tester.tap(find.byType(LightButton));
        await tester.pump();

        // 90 cm * 10 = 900 mm
        expect(fakeService.lastHeight, 900);
      });

      testWidgets('passes millimeters through without conversion', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_token');

        final DeviceManagementService Function(User user) factory = createFakeServiceFactory();
        await pumpRoute(tester, mockUser: mockUser, serviceFactory: factory);

        // Change unit to millimeters.
        await tester.tap(find.byType(DropdownButton<UnitOfMeasurement>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('mm').last);
        await tester.pumpAndSettle();

        // Enter a height of 750 mm.
        await tester.enterText(find.byType(TextField), '750');
        await tester.pump();

        // Tap the save button.
        await tester.tap(find.byType(LightButton));
        await tester.pump();

        expect(fakeService.lastHeight, 750);
      });

      testWidgets('converts feet to millimeters correctly', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_token');

        final DeviceManagementService Function(User user) factory = createFakeServiceFactory();
        await pumpRoute(tester, mockUser: mockUser, serviceFactory: factory);

        // Change unit to feet.
        await tester.tap(find.byType(DropdownButton<UnitOfMeasurement>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('ft').last);
        await tester.pumpAndSettle();

        // Enter a height of 3 feet.
        await tester.enterText(find.byType(TextField), '3');
        await tester.pump();

        // Tap the save button.
        await tester.tap(find.byType(LightButton));
        await tester.pump();

        // 3 feet * 304.8 = 914.4, rounded to 914
        expect(fakeService.lastHeight, 914);
      });

      testWidgets('converts meters to millimeters correctly', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_token');

        final DeviceManagementService Function(User user) factory = createFakeServiceFactory();
        await pumpRoute(tester, mockUser: mockUser, serviceFactory: factory);

        // Change unit to meters.
        await tester.tap(find.byType(DropdownButton<UnitOfMeasurement>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('m').last);
        await tester.pumpAndSettle();

        // Enter a height of 1 meter.
        await tester.enterText(find.byType(TextField), '1');
        await tester.pump();

        // Tap the save button.
        await tester.tap(find.byType(LightButton));
        await tester.pump();

        // 1 meter * 1000 = 1000 mm
        expect(fakeService.lastHeight, 1000);
      });
    });

    group('initial state', () {
      testWidgets('defaults to inches as the unit of measurement', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        await pumpRoute(tester, mockUser: mockUser);

        // The dropdown should display "in" for inches.
        expect(find.text('in'), findsOneWidget);
      });
    });
  });

  group('ApplianceMeasurementView', () {
    group('rendering', () {
      testWidgets('displays the title text', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        await pumpRoute(tester, mockUser: mockUser);

        expect(find.text('Height Measurement'), findsOneWidget);
      });

      testWidgets('displays the height input field', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        await pumpRoute(tester, mockUser: mockUser);

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('displays the save button', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        await pumpRoute(tester, mockUser: mockUser);

        expect(find.byType(LightButton), findsOneWidget);
        expect(find.text('SAVE'), findsOneWidget);
      });

      testWidgets('displays the unit of measurement dropdown', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        await pumpRoute(tester, mockUser: mockUser);

        expect(find.byType(DropdownButton<UnitOfMeasurement>), findsOneWidget);
      });

      testWidgets('displays an image of a water softener', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        await pumpRoute(tester, mockUser: mockUser);

        expect(find.byType(Image), findsOneWidget);
      });
    });

    group('unit selection', () {
      testWidgets('changing the unit updates the dropdown display', (WidgetTester tester) async {
        final MockUser mockUser = MockUser();
        when(mockUser.uid).thenReturn('test_uid');

        await pumpRoute(tester, mockUser: mockUser);

        // Open the dropdown.
        await tester.tap(find.byType(DropdownButton<UnitOfMeasurement>));
        await tester.pumpAndSettle();

        // Select centimeters.
        await tester.tap(find.text('cm').last);
        await tester.pumpAndSettle();

        // The dropdown should now show "cm".
        expect(find.text('cm'), findsOneWidget);
      });
    });
  });
}

/// A fake [DeviceManagementService] that records calls to [updateApplianceHeight] for test assertions.
class _FakeDeviceManagementService extends DeviceManagementService {
  _FakeDeviceManagementService({required super.user});

  /// The last device ID passed to [updateApplianceHeight].
  String? lastDeviceId;

  /// The last height value passed to [updateApplianceHeight].
  int? lastHeight;

  @override
  Future<void> updateApplianceHeight({required String deviceId, required int height}) async {
    lastDeviceId = deviceId;
    lastHeight = height;
  }
}
