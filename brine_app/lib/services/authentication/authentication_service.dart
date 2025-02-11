import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import '../firebase_emulator/dev_machine_ip.dart';
import 'models/auth_methods.dart';

/// A service class that handles authentication tasks with Firebase Auth.
///
/// This class provides static methods to perform various authentication actions, such as creating accounts with email
/// and password, signing in with Google, and signing out. It encapsulates the Firebase Auth operations for this app.
class AuthenticationService {
  /// The Firebase Auth [User] object representing the current user.
  final User user;

  /// Creates an instance of the [AuthenticationService] class with the specified [user].
  AuthenticationService({required this.user});

  /// The host for the Firebase Functions base URL.
  static const String _cloudFunctionsHost = kDebugMode ? devMachineIP : ''; // TODO(Toglefritz): update prod host

  /// The base URL for all endpoints used by this service.
  static String baseUrl = kDebugMode
      ? 'http://$_cloudFunctionsHost:5001/brine-3b212/us-central1'
      : ''; // TODO(Toglefritz): update prod endpoint

  /// Creates a password-based account with Firebase Auth.
  ///
  /// As part of creating a password-based account with Firebase Auth, a [FirebaseAuthException] can be thrown if
  /// issues with the provided username or password are discovered.
  static Future<User?> _createBasicAuthAccount({
    required String emailAddress,
    required String password,
  }) async {
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

  /// Creates a new user via Firebase Authentication.
  ///
  /// If an error occurs during the process, the error code and message are printed. Exceptions are rethrown.
  static Future<void> createUser({required AuthMethod method, String? emailAddress, String? password}) async {
    try {
      User? user;

      switch (method) {
        case AuthMethod.basicAuth:
          assert(
            emailAddress != null && password != null,
            'For authenticating with basic auth, the email and password must be provided',
          );

          user = await _createBasicAuthAccount(emailAddress: emailAddress!, password: password!);
          break;
        case AuthMethod.google:
          user = await signInWithGoogle();
          break;
        case AuthMethod.apple:
          // TODO(Toglefritz): Handle this case.
          break;
      }

      debugPrint('Authenticated with UID, ${user?.uid}');
    } catch (e) {
      debugPrint('Failed to create user with exception, $e');

      rethrow;
    }
  }

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
  static Future<User?> signInWithGoogle() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      final GoogleAuthProvider authProvider = GoogleAuthProvider();

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
            // TODO(Toglefritz): ...
            rethrow;
          } else if (e.code == 'invalid-credential') {
            // TODO(Toglefritz): ...
            rethrow;
          }
        } catch (e) {
          // TODO(Toglefritz): ...
          rethrow;
        }
      }
    }

    return user;
  }

  /// Logs the user out of the app via Firebase Auth.
  static Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes the user's document in the "users" collection of the Firestore database.
  Future<void> deleteUserDocument() async {
    try {
      // Get the authenticated user's Firebase ID token
      final String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      if (idToken == null) {
        throw Exception('User is not authenticated. Cannot delete user document.');
      }

      // Define the backend endpoint URL
      const String endpoint = '/deleteUser';

      // Make an authenticated HTTP DELETE request
      final Response response = await delete(
        Uri.parse(baseUrl + endpoint),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      // Check the response status code
      if (response.statusCode == 200) {
        debugPrint('Successfully deleted user document for UID: ${user.uid}');
      } else {
        throw Exception('Failed to delete user document: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error deleting user document: $e');
      throw Exception('Error deleting user document: $e');
    }
  }
}
