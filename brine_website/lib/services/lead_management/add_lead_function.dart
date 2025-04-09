import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

/// Submits a new lead to a Firebase Firestore vs a Firebase Cloud Function.
///
/// This function uses the Firebase Cloud Functions package to send a new lead to the 'addLead' Cloud Function. The
/// 'addLead' Cloud Function then adds this lead to the Firestore database. Anonymous authentication is used for the
/// `addLead` Cloud Function so this method authenticates using this method prior to calling the Cloud Function.
///
/// This function accepts three parameters:
///   - [email]: The email address of the lead.
///   - [name]: The name of the lead.
///
/// It returns a [Future] that completes once the data has been sent to the Firebase function. If an error occurs
/// while calling the Firebase function, this function catches the error and logs it to the console.
///
/// Example usage:
///
/// ```dart
/// await addLead('jeb@kerbalspaceprogram.gov', 'Jeb', DateTime.now().millisecondsSinceEpoch);
/// ```
Future<void> callAddLeadFunction({required String name, required String email}) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('addLead');
    final HttpsCallableResult<String> response = await callable.call(<String, dynamic>{
      'name': name,
      'email': email,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    debugPrint('Successfully executed addLead function: ${response.data}');
  } on FirebaseFunctionsException catch (e) {
    debugPrint('Failed to execute addLead function. Code: ${e.code}, Message: ${e.details}');
    rethrow;
  } catch (e) {
    debugPrint('Failed to execute addLead function: $e');
    rethrow;
  }
}
