import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_route.dart';
import 'login_view.dart';

/// Controller for [LoginRoute].
class LoginController extends State<LoginRoute> {
  /// A key used for the username and password login form.
  final loginFormKey = GlobalKey<FormState>();

  /// Handles submission of the username and password to perform basic authentication against Firebase.
  void handleBasicAuthLoginSubmit() {
    if (loginFormKey.currentState!.validate()) {
      // TODO perform basic auth
    }
  }

  /// Handles taps on the back button.
  void handleBackTap() {
    Navigator.pop(context);
  }

  /// Handles taps on the Google sign in button.
  Future<UserCredential> handleGoogleLogin() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  /// Handles taps on the Apple sign in button.
  void handleAppleLogin() {
    // TODO do login with Apple
  }

  /// Handles taps on the privacy policy link.
  void handleTermsAndConditionsTap() {
    // TODO open terms and conditions
  }

  /// Handles taps on the privacy policy link.
  void handlePrivacyPolicyTap() {
    // TODO open privacy policy
  }

  @override
  Widget build(BuildContext context) => LoginView(this);
}
