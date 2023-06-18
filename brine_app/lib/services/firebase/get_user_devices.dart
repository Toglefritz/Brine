import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Retrieves the list of devices for the authenticated user's account by calling the `getUserDevices` Firebase
/// callable function.
///
/// This function returns a `Future<List<String>>` containing the device IDs for the authenticated user. It throws an
/// error if there is an issue while calling the Firebase function, such as an unauthenticated user.
Future<List<String>> getUserDevices() async {
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
