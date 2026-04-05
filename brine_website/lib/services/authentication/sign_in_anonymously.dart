import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// This function is responsible for signing in a user anonymously using Firebase Authentication.
FirebaseAuth auth = FirebaseAuth.instance;

/// Signs in the user anonymously if they are not already signed in.
///
/// The Firebase Authentication instance is used to check if a user is currently signed in. If no user is signed in, the
/// function will sign in the user anonymously.
///
/// Anonymous sign in provides the app with a unique identifier for the user without requiring any manual login.
///
/// Example:
/// ```dart
/// signInAnonymously();
/// ```
Future<void> signInAnonymously() async {
  User? user = auth.currentUser;
  user ??= (await auth.signInAnonymously()).user;
  debugPrint('Logged in as ${user?.uid}');
}
