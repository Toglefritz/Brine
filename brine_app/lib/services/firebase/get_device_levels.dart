import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

/// Retrieves the salt level and battery level for the specified IoT device
/// associated with the authenticated user by calling the `getDeviceLevels`
/// Firebase callable function.
///
/// The Firestore structure consists of a "users" collection that stores user
/// documents with an array of associated device IDs, and a "devices" collection
/// that stores device documents with device ID, salt level, and battery level.
///
/// This function returns a `Future<Map<String, dynamic>>` containing the battery
/// level and salt level for the specified IoT device. It throws an error if there
/// is an issue while calling the Firebase function, such as an unauthenticated user
/// or lack of access to the specified device.
///
/// {@param String deviceId} - The device ID of the IoT device for which to retrieve
/// the salt level and battery level.
///
/// {@return Future<Map<String, dynamic>>} - A Future resolving to a map containing
/// the battery level and salt level for the specified IoT device.
///
/// {@example}
/// ```
/// try {
///   final deviceLevels = await getDeviceLevels('vast_teal_elephant');
///   print('Battery Level: ${deviceLevels['battery_level']}');
///   print('Salt Level: ${deviceLevels['salt_level']}');
/// } catch (error) {
///   print('Error getting device levels: $error');
/// }
/// ```
Future<Map<String, dynamic>> getDeviceLevels(String deviceId) async {
  try {
    // Create a reference to the 'getDeviceLevels' callable function
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getDeviceLevels');

    // Call the function with the device ID as an argument
    final response = await callable.call(<String, dynamic>{'deviceId': deviceId});

    // Get the battery level and salt level from the response
    double batteryLevel = response.data['battery_level'];
    double saltLevel = response.data['salt_level'];

    // Return the battery level and salt level as a map
    return {
      'battery_level': batteryLevel,
      'salt_level': saltLevel,
    };
  } catch (e) {
    debugPrint('Error getting device levels: $e');
    rethrow;
  }
}
