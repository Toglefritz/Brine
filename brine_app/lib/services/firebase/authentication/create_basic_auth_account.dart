import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Creates a password-based account with Firebase Auth.
///
/// As part of creating a password-based account with Firebase Auth, a [FirebaseAuthException] can be thrown if
/// issues with the provided username or password are discovered.
Future<User?> createBasicAuthAccount({required String emailAddress, required String password}) async {
  try {
    final UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );

    return credential.user;
  } on FirebaseAuthException catch (e) {
    debugPrint('FirebaseAuthException thrown during account creation: $e');

    rethrow;
  } catch (e) {
    debugPrint('Creating password-based account failed with exception, $e');

    rethrow;
  }
}