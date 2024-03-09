import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'models/brine_device.dart';

/// A service class for managing Brine IoT devices.
///
/// This class provides static methods to interact with devices associated with the authenticated user's account. It
/// utilizes Firebase Functions to communicate with the backend for retrieving device information such as device IDs,
/// and levels of salt and battery.
class DeviceManagementService {
  /// The base URL for all endpoints used by this service.
  static String baseUrl =
      kDebugMode ? 'http://127.0.0.1:5001/brine-3b212/us-central1' : ''; // TODO(Toglefritz): update prod endpoint

/*  /// Retrieves the list of devices for the authenticated user's account by calling the `getUserDevices` Firebase
  /// callable function.
  ///
  /// This function returns a [Future<List<String>>] containing the device IDs for the authenticated user. It throws an
  /// error if there is an issue while calling the Firebase function, such as an unauthenticated user.
  static Future<List<String>> getUserDevices() async {
    try {
      // Create a reference to the 'getUserDevices' callable function
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getUserDevices');

      // Call the function
      final HttpsCallableResult response = await callable.call();

      // Get the list of devices from the response
      List<String> devices = List<String>.from(response.data['devices']);

      // Return the list of devices
      return devices;
    } catch (e) {
      debugPrint('Error getting user devices: $e');

      rethrow;
    }
  }*/

  /// Calls the getUserDevicesHttp endpoint to retrieve the list of devices for the current user.
  /// Assumes the user is already authenticated with Firebase Auth.
  /// Returns a list of devices or throws an exception if an error occurs.
  static Future<List<String>> getUserDevicesHttp() async {
    try {
      // Get the current user
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      }

      // Get the user's ID token
      final String? idToken = await user.getIdToken();

      // Define the endpoint URL
      const String endpoint = '/getUserDevicesHttp';

      // Make an authenticated HTTP request to the endpoint
      final Response response = await get(
        Uri.parse(baseUrl + endpoint),
        // Include the ID token in the Authorization header
        headers: {'Authorization': 'Bearer $idToken'},
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> devicesJson = json.decode(response.body) as Map<String, dynamic>;
        final List<String> devices = List<String>.from(devicesJson['devices'] as List<String>);

        return devices;
      } else {
        // Handle errors or unexpected status codes
        throw Exception('Failed to load devices: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle any exceptions
      debugPrint('Failed to get user devices with exception, $e');
      throw Exception('Error getting devices: $e');
    }
  }

  /// Retrieves the salt level and battery level for the specified IoT device associated with the authenticated user
  /// by calling the [getDeviceLevels] Firebase callable function.
  ///
  /// The Firestore structure consists of a "users" collection that stores user documents with an array of associated
  /// device IDs, and a "devices" collection that stores device documents with device ID, salt level, and battery level.
  ///
  /// This function returns a [Future<[BrineDevice]>] containing the battery level and salt level for the specified
  /// IoT device, along with the device ID and a timestamp for when the salt and battery levels were last retrieved,
  /// which is the time when this function was last called.
  ///
  /// It throws an error if there is an issue while calling the Firebase function, such as an unauthenticated user or
  /// lack of access to the specified device.
  static Future<BrineDevice> getDeviceLevels(String deviceId) async {
    try {
      // Create a reference to the 'getDeviceLevels' callable function
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getDeviceLevels');

      // Call the function with the device ID as an argument
      final HttpsCallableResult<Map<String, dynamic>> response = await callable.call(<String, dynamic>{'deviceId': deviceId});

      // Get the salt level and battery level from the response
      final double saltLevel = response.data['salt_level'] as double;
      final double batteryLevel = response.data['battery_level'] as double;

      // Return the battery level and salt level as a map
      return BrineDevice(
        deviceId: deviceId,
        saltLevel: saltLevel,
        batteryLevel: batteryLevel,
        retrievalTimestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting device levels: $e');

      rethrow;
    }
  }
}
