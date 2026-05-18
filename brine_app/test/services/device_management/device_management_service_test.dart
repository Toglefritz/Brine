import 'dart:convert';
import 'dart:io';

import 'package:brine/services/device_management/device_management_service.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:fake_http_client/fake_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_user.mocks.dart';
import '../../utils/mock_http_server.dart';

/// This file contains tests for the [DeviceManagementService] class.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/services/device_management/device_management_service_test.dart
/// ```
void main() {
  group('DeviceManagementService', () {
    /// This group contains tests for the `addDeviceToAccount` method.
    group('addDeviceToAccount', () {
      /// This test verifies that the `addDeviceToAccount` method successfully adds the device to the user account.
      test('should successfully add the device to the user account', () async {
        // Set up the mock response body.
        final Map<String, dynamic> responseBody = {
          'message': 'Device added successfully',
        };

        // Set up the mock response data.
        final Map<String, dynamic> mockResponseData = {
          'statusCode': 200,
          'body': responseBody,
        };

        // Create a MockHttpServer instance with the responseBuilder function.
        final MockHttpServer mockServer = MockHttpServer(() {
          return FakeHttpResponse(
            statusCode: mockResponseData['statusCode'] as int,
            body: jsonEncode(mockResponseData['body']),
          );
        });

        // Set the global HttpOverrides to use the MockHttpServer.
        HttpOverrides.global = mockServer;

        // Mock getting an ID token for the user
        final MockUser mockUser = MockUser();
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_id_token');

        // Create an instance of the DeviceManagementService class using the mock user.
        final DeviceManagementService deviceManagementService = DeviceManagementService(user: mockUser);

        // Create a test instance of BrineDevice
        final BrineDevice device = BrineDevice(
          deviceId: 'mock_device_id',
          name: 'mock_device_name',
          saltDistance: 100,
          applianceHeight: 200,
          saltLevel: 0.5,
          batteryLevel: 0.8,
          lastUpdatedTimestamp: DateTime.now(),
          retrievalTimestamp: DateTime.now(),
        );

        // Call the function under test.
        await deviceManagementService.addDeviceToAccount(
          device: device,
        );

        // Clean up by resetting the global HttpOverrides.
        HttpOverrides.global = null;
      });
    });

    /// This group contains tests for the `updateApplianceHeight` method.
    group('updateApplianceHeight', () {
      /// This test verifies that the `updateApplianceHeight` method successfully updates the appliance height.
      test('should successfully update the appliance height', () async {
        // Set up the mock response body.
        final Map<String, dynamic> responseBody = {
          'message': 'Appliance height updated successfully',
        };

        // Set up the mock response data.
        final Map<String, dynamic> mockResponseData = {
          'statusCode': 200,
          'body': responseBody,
        };

        // Create a MockHttpServer instance with the responseBuilder function.
        final MockHttpServer mockServer = MockHttpServer(() {
          return FakeHttpResponse(
            statusCode: mockResponseData['statusCode'] as int,
            body: jsonEncode(mockResponseData['body']),
          );
        });

        // Set the global HttpOverrides to use the MockHttpServer.
        HttpOverrides.global = mockServer;

        // Mock getting an ID token for the user
        final MockUser mockUser = MockUser();
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_id_token');

        // Create an instance of the DeviceManagementService class using the mock user.
        final DeviceManagementService deviceManagementService = DeviceManagementService(user: mockUser);

        // Call the function under test.
        await deviceManagementService.updateApplianceHeight(
          deviceId: 'mock_device_id',
          height: 100,
        );

        // Clean up by resetting the global HttpOverrides.
        HttpOverrides.global = null;
      });
    });

    /// This group contains tests for the `getUserDevices` method.
    group('getUserDevices', () {
      /// This test verifies that the `getUserDevices` method successfully retrieves the user's devices.
      test('should successfully retrieve the user\'s devices', () async {
        // Set up the mock response body. The service expects a "devices" key containing a list of device JSON objects
        // matching the BrineDevice.fromJson schema.
        final Map<String, dynamic> responseBody = {
          'devices': [
            {
              'device_id': 'crimson_gentle_panther',
              'name': 'a1b2',
              'salt_distance': 150,
              'appliance_height': 300,
              'battery_level': 0.9,
              'last_updated': '2025-05-01T12:00:00.000Z',
            },
            {
              'device_id': 'luminous_cobalt_eagle',
              'name': 'c3d4',
              'salt_distance': 100,
              'appliance_height': 400,
              'battery_level': 0.75,
              'last_updated': '2025-05-02T08:30:00.000Z',
            },
          ],
        };

        // Set up the mock response data.
        final Map<String, dynamic> mockResponseData = {
          'statusCode': 200,
          'body': responseBody,
        };

        // Create a MockHttpServer instance with the responseBuilder function.
        final MockHttpServer mockServer = MockHttpServer(() {
          return FakeHttpResponse(
            statusCode: mockResponseData['statusCode'] as int,
            body: jsonEncode(mockResponseData['body']),
          );
        });

        // Set the global HttpOverrides to use the MockHttpServer.
        HttpOverrides.global = mockServer;

        // Mock getting an ID token for the user
        final MockUser mockUser = MockUser();
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_id_token');

        // Create an instance of the DeviceManagementService class using the mock user.
        final DeviceManagementService deviceManagementService = DeviceManagementService(user: mockUser);

        // Call the function under test.
        final List<BrineDevice> devices = await deviceManagementService.getUserDevices();

        // Clean up by resetting the global HttpOverrides.
        HttpOverrides.global = null;

        // Verify the result.
        expect(devices.length, 2);
        expect(devices[0].deviceId, 'crimson_gentle_panther');
        expect(devices[1].deviceId, 'luminous_cobalt_eagle');
      });
    });

    /// This group contains tests for the `getDeviceLevels` method.
    group('getDeviceLevels', () {
      /// This test verifies that the `getDeviceLevels` method successfully retrieves the device levels.
      test('should successfully retrieve the device levels', () async {
        // Set up the mock response body. The service passes this directly to BrineDevice.fromJson, which expects
        // salt_distance, appliance_height, battery_level, last_updated, device_id, and name.
        final Map<String, dynamic> responseBody = {
          'device_id': 'silent_emerald_tiger',
          'name': '7b67',
          'salt_distance': 150,
          'appliance_height': 300,
          'battery_level': 0.7,
          'last_updated': '2025-05-10T10:00:00.000Z',
        };

        // Set up the mock response data.
        final Map<String, dynamic> mockResponseData = {
          'statusCode': 200,
          'body': responseBody,
        };

        // Create a MockHttpServer instance with the responseBuilder function.
        final MockHttpServer mockServer = MockHttpServer(() {
          return FakeHttpResponse(
            statusCode: mockResponseData['statusCode'] as int,
            body: jsonEncode(mockResponseData['body']),
          );
        });

        // Set the global HttpOverrides to use the MockHttpServer.
        HttpOverrides.global = mockServer;

        // Mock getting an ID token for the user
        final MockUser mockUser = MockUser();
        when(mockUser.getIdToken()).thenAnswer((_) async => 'silent_emerald_tiger');

        // Create an instance of the DeviceManagementService class using the mock user.
        final DeviceManagementService deviceManagementService = DeviceManagementService(user: mockUser);

        // Call the function under test.
        final BrineDevice brineDevice = await deviceManagementService.getDeviceLevels('silent_emerald_tiger');

        // Clean up by resetting the global HttpOverrides.
        HttpOverrides.global = null;

        // Verify the result.
        expect(brineDevice.deviceId, 'silent_emerald_tiger');
        expect(brineDevice.name, '7b67');
        expect(brineDevice.saltDistance, 150.0);
        expect(brineDevice.applianceHeight, 300.0);
        expect(brineDevice.saltLevel, 0.5); // 150 / 300 = 0.5
        expect(brineDevice.batteryLevel, 0.7);
      });
    });

    /// This group contains tests for the `createUserDocument` method.
    group('createUserDocument', () {
      test('should successfully create a user document', () async {
        final Map<String, dynamic> responseBody = {'message': 'User document created'};
        final MockHttpServer mockServer = MockHttpServer(() {
          return FakeHttpResponse(statusCode: 200, body: jsonEncode(responseBody));
        });
        HttpOverrides.global = mockServer;

        final MockUser mockUser = MockUser();
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_id_token');
        when(mockUser.uid).thenReturn('test_uid');

        final DeviceManagementService service = DeviceManagementService(user: mockUser);
        await service.createUserDocument();

        HttpOverrides.global = null;
      });

      test('should throw when the response status code is not 200 or 201', () async {
        final MockHttpServer mockServer = MockHttpServer(() {
          return FakeHttpResponse(statusCode: 500, body: 'Internal Server Error');
        });
        HttpOverrides.global = mockServer;

        final MockUser mockUser = MockUser();
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_id_token');

        final DeviceManagementService service = DeviceManagementService(user: mockUser);

        expect(() => service.createUserDocument(), throwsException);

        HttpOverrides.global = null;
      });
    });

    /// This group contains tests for the `generatePreSharedKey` method.
    group('generatePreSharedKey', () {
      test('should successfully generate and return a pre-shared key', () async {
        final Map<String, dynamic> responseBody = {
          'psk': '7caf96e97207a08a4a90b9a845d7259703f255790f8384f812fe44c605e1d23b',
        };
        final MockHttpServer mockServer = MockHttpServer(() {
          return FakeHttpResponse(statusCode: 200, body: jsonEncode(responseBody));
        });
        HttpOverrides.global = mockServer;

        final MockUser mockUser = MockUser();
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_id_token');

        final DeviceManagementService service = DeviceManagementService(user: mockUser);
        final dynamic psk = await service.generatePreSharedKey(deviceId: 'test_device');

        HttpOverrides.global = null;

        expect(psk.value, '7caf96e97207a08a4a90b9a845d7259703f255790f8384f812fe44c605e1d23b');
      });

      test('should throw when the response status code is not 200', () async {
        final MockHttpServer mockServer = MockHttpServer(() {
          return FakeHttpResponse(statusCode: 403, body: 'Forbidden');
        });
        HttpOverrides.global = mockServer;

        final MockUser mockUser = MockUser();
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_id_token');

        final DeviceManagementService service = DeviceManagementService(user: mockUser);

        expect(() => service.generatePreSharedKey(deviceId: 'test_device'), throwsException);

        HttpOverrides.global = null;
      });
    });

    /// This group contains tests for the `removeDeviceFromAccount` method.
    group('removeDeviceFromAccount', () {
      test('should successfully remove a device from the account', () async {
        final MockHttpServer mockServer = MockHttpServer(() {
          return FakeHttpResponse(statusCode: 200, body: jsonEncode({'message': 'Device removed'}));
        });
        HttpOverrides.global = mockServer;

        final MockUser mockUser = MockUser();
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_id_token');

        final DeviceManagementService service = DeviceManagementService(user: mockUser);
        await service.removeDeviceFromAccount(deviceId: 'test_device_id');

        HttpOverrides.global = null;
      });

      test('should throw when the response status code is not 200', () async {
        final MockHttpServer mockServer = MockHttpServer(() {
          return FakeHttpResponse(statusCode: 404, body: 'Not Found');
        });
        HttpOverrides.global = mockServer;

        final MockUser mockUser = MockUser();
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_id_token');

        final DeviceManagementService service = DeviceManagementService(user: mockUser);

        expect(() => service.removeDeviceFromAccount(deviceId: 'test_device_id'), throwsException);

        HttpOverrides.global = null;
      });
    });

    /// This group contains tests for error handling in existing methods.
    group('error handling', () {
      test('getUserDevices should throw AuthenticationException on 401 response', () async {
        final MockHttpServer mockServer = MockHttpServer(() {
          return FakeHttpResponse(statusCode: 401, body: 'Unauthorized');
        });
        HttpOverrides.global = mockServer;

        final MockUser mockUser = MockUser();
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_id_token');

        final DeviceManagementService service = DeviceManagementService(user: mockUser);

        expect(() => service.getUserDevices(), throwsA(isA<Exception>()));

        HttpOverrides.global = null;
      });

      test('addDeviceToAccount should throw on non-200 response', () async {
        final MockHttpServer mockServer = MockHttpServer(() {
          return FakeHttpResponse(statusCode: 500, body: 'Server Error');
        });
        HttpOverrides.global = mockServer;

        final MockUser mockUser = MockUser();
        when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_id_token');

        final DeviceManagementService service = DeviceManagementService(user: mockUser);
        final BrineDevice device = BrineDevice(
          deviceId: 'test',
          name: 'test',
          saltDistance: 100,
          applianceHeight: 200,
          saltLevel: 0.5,
          batteryLevel: 0.8,
          lastUpdatedTimestamp: DateTime.now(),
          retrievalTimestamp: DateTime.now(),
        );

        expect(() => service.addDeviceToAccount(device: device), throwsException);

        HttpOverrides.global = null;
      });
    });
  });
}
