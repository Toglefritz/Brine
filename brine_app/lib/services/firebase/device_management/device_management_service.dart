import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'models/brine_device.dart';

/// A service class for managing Brine IoT devices.
///
/// This class provides static methods to interact with devices associated with the authenticated user's account. It
/// utilizes Firebase Functions to communicate with the backend for retrieving device information such as device IDs,
/// and levels of salt and battery.
class DeviceManagementService {
  /// Retrieves the list of devices for the authenticated user's account by calling the `getUserDevices` Firebase
  /// callable function.
  ///
  /// This function returns a [Future<List<String>>] containing the device IDs for the authenticated user. It throws an
  /// error if there is an issue while calling the Firebase function, such as an unauthenticated user.
  static Future<List<String>> getUserDevices() async {
    try {
      // Create a reference to the 'getUserDevices' callable function
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getUserDevices');

      // Call the function
      final response = await callable.call();

      // Get the list of devices from the response
      List<String> devices = List<String>.from(response.data['devices']);

      // Return the list of devices
      return devices;
    } catch (e) {
      debugPrint('Error getting user devices: $e');

      rethrow;
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
  static Future<BrineDevice> getDevice(String deviceId) async {
    try {
      // Create a reference to the 'getDeviceLevels' callable function
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getDeviceLevels');

      // Call the function with the device ID as an argument
      final response = await callable.call(<String, dynamic>{'deviceId': deviceId});

      // Get the salt level and battery level from the response
      double saltLevel = response.data['salt_level'].toDouble();
      double batteryLevel = response.data['battery_level'].toDouble();

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