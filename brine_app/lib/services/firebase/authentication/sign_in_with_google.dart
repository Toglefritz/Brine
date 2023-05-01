import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
