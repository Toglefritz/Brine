import 'package:brine/screens/authentication/onboarding/onboarding_route.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../values/regex.dart';
import 'login_route.dart';
import 'login_view.dart';

/// Controller for [LoginRoute].
class LoginController extends State<LoginRoute> {
  /// A key used for the username and password login form.
  final loginFormKey = GlobalKey<FormState>();

  /// A controller used for the username field.
  final usernameFieldController = TextEditingController();

  /// A controller used for the password field.
  final passwordFieldController = TextEditingController();

  /// Determines if the username field is in an error state, which is, in turn, determined by the
  /// [validateUsernameField] method.
  bool usernameFieldError = false;

  /// Determines if the password field is in an error state, which is, in turn, determined by the
  /// [validatePasswordField] method.
  bool passwordFieldError = false;

  /// Handles submission of the username and password to perform basic authentication against Firebase.
  void handleBasicAuthLoginSubmit() {
    if (loginFormKey.currentState!.validate()) {
      // TODO perform basic auth
    }
  }

  /// Validates the username field.
  String? validateUsernameField(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        usernameFieldError = true;
      });

      return 'Oh no! Please enter a username.';
    } else if (!RegEx.emailAddress.hasMatch(value)) {
      setState(() {
        usernameFieldError = true;
      });

      return 'Is this a valid email address?';
    }

    setState(() {
      usernameFieldError = false;
    });

    return null;
  }

  /// Validates the password field.
  String? validatePasswordField(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        passwordFieldError = true;
      });

      return 'Please enter a password.';
    } else if (value.length < 6) {
      setState(() {
        passwordFieldError = true;
      });

      return 'You\'ll need a longer password.';
    }

    setState(() {
      passwordFieldError = false;
    });

    return null;
  }

  /// Handles taps on the back button.
  void handleBackTap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const OnboardingRoute(),
      ),
    );
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

  @override
  Widget build(BuildContext context) => LoginView(this);
}
