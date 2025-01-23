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
        final DeviceManagementService deviceManagementService =
            DeviceManagementService(user: mockUser);

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
        final DeviceManagementService deviceManagementService =
            DeviceManagementService(user: mockUser);

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
        // Set up the mock response body.
        final Map<String, dynamic> responseBody = {
          'deviceIds': ['crimson_gentle_panther', 'luminous_cobalt_eagle'],
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
        final DeviceManagementService deviceManagementService =
            DeviceManagementService(user: mockUser);

        // Call the function under test.
        final List<String> deviceIds =
            await deviceManagementService.getUserDevices();

        // Clean up by resetting the global HttpOverrides.
        HttpOverrides.global = null;

        // Verify the result.
        expect(deviceIds, ['crimson_gentle_panther', 'luminous_cobalt_eagle']);
      });
    });

    /// This group contains tests for the `getDeviceLevels` method.
    group('getDeviceLevels', () {
      /// This test verifies that the `getDeviceLevels` method successfully retrieves the device levels.
      test('should successfully retrieve the device levels', () async {
        // Set up the mock response body.
        final Map<String, dynamic> responseBody = {
          'device_id': 'silent_emerald_tiger',
          'salt_level': 0.5,
          'battery_level': 0.7,
          'name': '7b67',
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
        when(mockUser.getIdToken())
            .thenAnswer((_) async => 'silent_emerald_tiger');

        // Create an instance of the DeviceManagementService class using the mock user.
        final DeviceManagementService deviceManagementService =
            DeviceManagementService(user: mockUser);

        // Call the function under test.
        final BrineDevice brineDevice = await deviceManagementService
            .getDeviceLevels('silent_emerald_tiger');

        // Clean up by resetting the global HttpOverrides.
        HttpOverrides.global = null;

        // Verify the result.
        expect(brineDevice.deviceId, 'silent_emerald_tiger');
        expect(brineDevice.saltLevel, 0.5);
        expect(brineDevice.batteryLevel, 0.7);
        expect(brineDevice.name, '7b67');
      });
    });
  });
}
