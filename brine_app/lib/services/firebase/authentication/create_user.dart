import 'package:brine/services/firebase/authentication/sign_in_with_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'auth_methods.dart';
import 'create_basic_auth_account.dart';

/// Calls the 'createUser' Firebase Cloud Function to create a new user document in Firestore.
///
/// This function requires the client to be authenticated. If the client is not authenticated, it will automatically
/// authenticate anonymously.
///
/// The authenticated user's UID is used as both the document ID and the uid field value in the document in Firestore.
/// An empty devices array is also added to the document.
///
/// If an error occurs during the process, the error code and message are printed. Exceptions are rethrown.
Future<void> createUser({required AuthMethod method, String? emailAddress, String? password}) async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    switch (method) {
      case AuthMethod.basicAuth:
        assert(emailAddress != null && password != null,
            'For authenticating with basic auth, the email and password must be provided');

        user = await createBasicAuthAccount(emailAddress: emailAddress!, password: password!);
        break;
      case AuthMethod.google:
        user = await signInWithGoogle();
        break;
      case AuthMethod.apple:
        // TODO: Handle this case.
        break;
    }

    // Ensure that the user is logged in before making the call
    user ??= (await auth.signInAnonymously()).user;

    debugPrint('Authenticated with UID, ${user?.uid}');

    // TODO if anonymous login is used, provide a mechanism for transferring to regular login

    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createUser');
    final HttpsCallableResult results = await callable.call();
    debugPrint(results.data['result']); // { result: "User with UID xxx added." }
  } catch (e) {
    debugPrint('Failed to execute createUser function with exception, $e');

    rethrow;
  }
}
