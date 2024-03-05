import 'package:brine/services/firebase/authentication/sign_in_with_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_methods.dart';
import 'create_basic_auth_account.dart';

/// Creates a new user via Firebase Authentication.
///
/// If an error occurs during the process, the error code and message are printed. Exceptions are rethrown.
Future<void> createUser({required AuthMethod method, String? emailAddress, String? password}) async {
  try {
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

    debugPrint('Authenticated with UID, ${user?.uid}');
  } catch (e) {
    debugPrint('Failed to create user with exception, $e');

    rethrow;
  }
}
