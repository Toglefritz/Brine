import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Asynchronously signs the user in using Google authentication.
///
/// If the platform is web, it uses Firebase's `signInWithPopup` method for signing in the user with Google. For other
/// platforms, it uses the 'signIn` method from the `GoogleSignIn` package to sign in the user and then Firebase's
///
/// `signInWithCredential` method to authenticate with Firebase using the obtained credentials.
///
/// If the sign-in process encounters an error, it logs the error and rethrows the exception.
///
/// If the user is successfully authenticated, this function returns the authenticated `User`. If the user is not
/// successfully authenticated, it returns `null`.
Future<User?> signInWithGoogle() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  if (kIsWeb) {
    GoogleAuthProvider authProvider = GoogleAuthProvider();

    try {
      final UserCredential userCredential = await auth.signInWithPopup(authProvider);

      user = userCredential.user;
    } catch (e) {
      debugPrint('Failed to sign in with Google with exception, $e');
    }
  } else {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential = await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // TODO ...
          rethrow;
        } else if (e.code == 'invalid-credential') {
          // TODO ...
          rethrow;
        }
      } catch (e) {
        // TODO ...
        rethrow;
      }
    }
  }

  return user;
}
