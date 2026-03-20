import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

/// A service class responsible for submitting leads to the backend.
///
/// This service authenticates the request using anonymous sign-in and sends a
/// POST request to the Firebase Function endpoint that creates a new lead
/// document in Firestore.
class LeadsService {
  /// Submits a new lead to the backend via HTTP POST.
  ///
  /// [name] and [email] are the required parameters. A timestamp is automatically added.
  Future<void> submitLead({required String name, required String email}) async {
    try {
      // Ensure the user is signed in anonymously.
      final UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      final String? idToken = await userCredential.user?.getIdToken();

      // Check if the ID token is null. If it is, throw an exception.
      if (idToken == null) {
        throw Exception('Unable to retrieve ID token for anonymous user.');
      }

      // Define the endpoint for the add lead function.
      final Uri uri;

      // In debug mode, use the local emulator.
      if (kDebugMode) {
        uri = Uri.parse('http://127.0.0.1:5001/brine-3b212/us-central1/addLead');
      }
      // Otherwise, use the production endpoint.
      else {
        uri = Uri.parse('https://us-central1-brine-2c0a3.cloudfunctions.net/addLead');
      }

      final Response response = await post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
        }),
      );

      // Check the response status code.
      if (response.statusCode == 200) {
        debugPrint('Successfully submitted lead');
      }
      // If the status code is not 200, log the error.
      else {
        debugPrint('Failed to submit lead. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Lead submission failed');
      }
    } catch (e) {
      debugPrint('Failed to submit lead: $e');
      rethrow;
    }
  }
}
