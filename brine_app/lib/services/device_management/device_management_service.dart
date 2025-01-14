import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'models/brine_device.dart';
import '../firebase_emulator/dev_machine_ip.dart';
import 'models/pre_shared_key.dart';

/// A service class for managing Brine IoT devices.
///
/// This class provides static methods to interact with devices associated with the authenticated user's account. It
/// utilizes Firebase Functions to communicate with the backend for adding devices to the user's account, retrieving
/// device information such as device IDs, and levels of salt and battery. All of this information about the devices
/// is stored in Firestore.
class DeviceManagementService {
  /// The Firebase Auth [User] object representing the current user.
  final User user;

  /// Creates an instance of the [DeviceManagementService] class with the specified [user].
  DeviceManagementService({required this.user});

  static const String _cloudFunctionsHost = kDebugMode ? devMachineIP : ''; // TODO(Toglefritz): update prod host

  /// The base URL for all endpoints used by this service.
  static String baseUrl = kDebugMode
      ? 'http://$_cloudFunctionsHost:5001/brine-3b212/us-central1'
      : ''; // TODO(Toglefritz): update prod endpoint

  /// Calls the *addDeviceToAccount* endpoint to add a new device to the authenticated user's account. The Firebase
  /// backend will also create a record for the Brine device in the "devices" collection if one does not already exist.
  ///
  /// In the Brine Firestore database, each user has a document in the "users" collection that contains an array of
  /// device IDs associated with that user. By the time this function is called, the app assumes that the user has
  /// already created an account so a record wll already exist for their user ID in the "users" collection. For example,
  ///
  /// ```json
  /// {
  ///  "uid": "1234567890",
  ///  "devices": ["vast_teal_elephant",]
  ///  }
  ///  ```
  ///
  /// Information about the devices themselves is stored in the "devices" collection. The device ID of each device
  /// ties these two collections together. For example,
  ///
  /// ```json
  /// {
  /// "device_id": "vast_teal_elephant",
  /// "name": "7b67",
  /// "salt_level": 0.5,
  /// "battery_level": 0.8,
  /// }
  /// ```
  ///
  /// The [addDeviceToAccount] function takes a [BrineDevice] instance as a parameters.
  Future<void> addDeviceToAccount({required BrineDevice device}) async {
    try {
      // Get the user's ID token
      final String? idToken = await user.getIdToken();

      // Define the endpoint URL
      const String endpoint = '/addDeviceToUser';

      // Make an authenticated HTTP request to the endpoint
      final Response response = await post(
        Uri.parse(baseUrl + endpoint),
        // Include the ID token in the Authorization header
        headers: {'Authorization': 'Bearer $idToken'},
        body: {
          'deviceId': device.deviceId,
          'deviceName': device.name.toLowerCase(),
        },
      );

      // Check the response status code
      if (response.statusCode == HttpStatus.ok) {
        debugPrint('Successfully added the Brine monitor with device ID, ${device.name}, to the user\'s account');

        return;
      }
      // A non-200 status code was returned.
      else {
        throw Exception('Account association failed with reason phrase, ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Failed to associate the device with exception, $e');

      throw Exception('Failed to associate the device with exception, $e');
    }
  }

  /// In order to calculate the salt level in the water softener in terms of a percentage, the Brine system needs to
  /// know the height of the water softener. This allows the distance measurements from the Brine device to be
  /// translated into a percentage of remaining salt in the water softener. This function sends the height of the
  /// water softener to the Firestore backend where it is stored and used in the calculation.
  Future<void> updateApplianceHeight({required String deviceId, required int height}) async {
    try {
      // Get the user's ID token
      final String? idToken = await user.getIdToken();

      // Define the endpoint URL
      const String endpoint = '/updateApplianceHeight';

      // Make an authenticated HTTP request to the endpoint
      final Response response = await patch(
        Uri.parse(baseUrl + endpoint),
        // Include the ID token in the Authorization header
        headers: {'Authorization': 'Bearer $idToken'},
        body: {
          'deviceId': deviceId,
          'applianceHeight': height.toString(),
        },
      );

      // Check the response status code
      if (response.statusCode == HttpStatus.ok) {
        debugPrint('Successfully set the appliance height to $height');

        return;
      }
      // A non-200 status code was returned.
      else {
        throw Exception('Setting appliance height failed with reason phrase, ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Failed to set appliance height with exception, $e');
      throw Exception('Failed to set appliance height with exception, $e');
    }
  }

  /// Calls the *getUserDevicesHttp* endpoint to retrieve the list of devices for the current user. Assumes the user
  /// is already authenticated with Firebase Auth. Returns a list of devices or throws an exception if an error occurs.
  // TODO(Toglefritz): update this method to call the getDeviceLevels function and return a list of BrineDevice instead
  Future<List<String>> getUserDevices() async {
    try {
      // Get the user's ID token
      final String? idToken = await user.getIdToken();

      // Define the endpoint URL
      const String endpoint = '/getUserDevices';

      // Make an authenticated HTTP request to the endpoint
      final Response response = await get(
        Uri.parse(baseUrl + endpoint),
        // Include the ID token in the Authorization header
        headers: {'Authorization': 'Bearer $idToken'},
      );

      // Check the response status code
      if (response.statusCode == HttpStatus.ok) {
        debugPrint('Successfully got user deviceIds: ${response.body}');

        // Parse the response body
        final Map<String, dynamic> devicesJson = json.decode(response.body) as Map<String, dynamic>;
        final List<String> deviceIds = List<String>.from(devicesJson['devices'] as List<dynamic>);

        return deviceIds;
      } else {
        // Handle errors or unexpected status codes
        throw Exception('Failed to load deviceIds: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle any exceptions
      debugPrint('Failed to get user deviceIds with exception, $e');
      throw Exception('Error getting deviceIds: $e');
    }
  }

  /// Retrieves the salt level and battery level for the specified IoT device associated with the authenticated user
  /// by calling the [getDeviceLevels] Firebase callable function.
  ///
  /// The Firestore structure consists of a "users" collection that stores user documents with an array of associated
  /// device IDs, and a "devices" collection that stores device documents with device ID, salt level, and battery level.
  ///
  /// This function returns a [Future<BrineDevice>] containing the battery level and salt level for the specified
  /// IoT device, along with the device ID and a timestamp for when the salt and battery levels were last retrieved,
  /// which is the time when this function was last called.
  ///
  /// It throws an error if there is an issue while calling the Firebase function, such as an unauthenticated user or
  /// lack of access to the specified device.
  Future<BrineDevice> getDeviceLevels(String deviceId) async {
    try {
      // Get the user's ID token
      final String? idToken = await user.getIdToken();

      // Define the endpoint URL
      const String endpoint = '/getDevice';

      // Define the query parameter for the device ID
      final String query = '?deviceId=$deviceId';

      // Make an HTTP GET request to the endpoint
      final Response response = await post(
        Uri.parse(baseUrl + endpoint + query),
        // Include the ID token in the Authorization header
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == HttpStatus.ok) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;

        // Construct and return the BrineDevice object
        final BrineDevice device = BrineDevice.fromJson(data);

        return device;
      } else {
        throw Exception('Failed to load device levels: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error getting device levels: $e');

      rethrow;
    }
  }

  /// Calls the Firebase endpoint to generate a new pre-shared key (PSK) for a Brine device during provisioning.
  ///
  /// This function sends a POST request to the `generatePSK` Firebase Cloud Function endpoint with the
  /// unique device ID of the Brine device. The backend generates a secure random PSK, stores it in Firestore,
  /// and returns it to the mobile app. The mobile app then transfers this PSK securely to the Brine device
  /// over Bluetooth.
  ///
  /// A **pre-shared key (PSK)** is a secret key used for authenticating and securing communication between
  /// the Brine device and the Firebase backend. The Brine device uses the PSK to sign requests using an
  /// HMAC (Hash-Based Message Authentication Code). When the device sends a request, the backend verifies
  /// the HMAC signature using the stored PSK, ensuring that only devices with valid keys can access protected
  /// resources.
  ///
  /// **Security Notes**:
  /// - The PSK is handled only ephemerally by the mobile app during the provisioning process; it is not stored
  ///   persistently on the app.
  /// - The backend stores the PSK along with metadata such as the creation timestamp and validity status.
  /// - If a device is compromised, the PSK can be revoked, and a new PSK can be issued through re-provisioning.
  Future<PreSharedKey> generatePreSharedKey({required String deviceId}) async {
    try {
      // Get the user's ID token
      final String? idToken = await user.getIdToken();

      // Define the endpoint URL
      const String endpoint = '/generatePSK';

      // Create the body of the request containing the device ID.
      final Map<String, dynamic> body = {
        'deviceId': deviceId,
      };

      // Make an HTTP GET request to the endpoint
      final Response response = await post(
        Uri.parse(baseUrl + endpoint),
        // Include the ID token in the Authorization header
        headers: {'Authorization': 'Bearer $idToken'},
        body: body,
      );

      if (response.statusCode == HttpStatus.ok) {
        // Parse the JSON response
        final String psk = response.body;

        // Create a PreSharedKey instance from the string.
        final PreSharedKey preSharedKey = PreSharedKey(psk);

        // Return  the PSK.
        return preSharedKey;
      } else {
        throw Exception('Failed to get device PSK: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error getting device PSK: $e');

      rethrow;
    }
  }
}
