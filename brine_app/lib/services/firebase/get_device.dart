import 'package:brine/services/firebase/exceptions/get_device_exception.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'models/brine_device.dart';

/// Retrieves the salt level and battery level for the specified IoT device
/// associated with the authenticated user by calling the `getDeviceLevels`
/// Firebase callable function.
///
/// The Firestore structure consists of a "users" collection that stores user
/// documents with an array of associated device IDs, and a "devices" collection
/// that stores device documents with device ID, salt level, and battery level.
///
/// This function returns a `Future<[BrineDevice]>` containing the battery
/// level and salt level for the specified IoT device, along with the device
/// ID and a timestamp for when the salt and battery levels were last retrieved,
/// which is the time when this function was last called.. It throws an error
/// if there is an issue while calling the Firebase function, such as an
/// unauthenticated user or lack of access to the specified device.
///
/// ```
/// try {
///   final BrineDevice device = await getDevice('vast_teal_elephant');
///   print('Battery Level: ${device.batteryLevel}');
///   print('Salt Level: ${device.saltLevel}');
/// } catch (error) {
///   print('Error getting device levels: $error');
/// }
/// ```
Future<BrineDevice> getDevice(String deviceId) async {
  try {
    // Create a reference to the 'getDeviceLevels' callable function
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('getDeviceLevels');

    // Call the function with the device ID as an argument
    final response =
        await callable.call(<String, dynamic>{'deviceId': deviceId});

    // Get the salt level and battery level from the response
    double saltLevel = response.data['salt_level'];
    double batteryLevel = response.data['battery_level'];

    // Return the battery level and salt level as a map
    return BrineDevice(
      deviceId: deviceId,
      saltLevel: saltLevel,
      batteryLevel: batteryLevel,
      retrievalTimestamp: DateTime.now(),
    );
  } catch (e) {
    debugPrint('Error getting device levels: $e');

    throw GetDeviceException('Failed to get device details with exception, $e');
  }
}
