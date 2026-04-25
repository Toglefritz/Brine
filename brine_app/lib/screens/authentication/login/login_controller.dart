import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../../services/analytics/analytics.dart';
import '../../../services/authentication/authentication_service.dart';
import '../../../values/regex.dart';
import '../../setup/setup_route.dart';
import '../onboarding/onboarding_route.dart';
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

  /// An additional error string set by exceptions thrown during the login process related to the username entry.
  String? loginUsernameExceptionError;

  /// An additional error string set by exceptions thrown during the login process related to the password entry.
  String? loginPasswordExceptionError;

  /// Determines if the account creation process is in progress
  bool loginProcessing = false;

  /// Handles submission of the username and password to perform basic authentication against Firebase.
  Future<void> handleBasicAuthLoginSubmit() async {
    setState(() {
      loginUsernameExceptionError = null;
      loginPasswordExceptionError = null;
      usernameFieldError = false;
      passwordFieldError = false;
      loginProcessing = true;
    });

    if (loginFormKey.currentState!.validate()) {
      setState(() {
        loginProcessing = true;
      });

      try {
        await login(
          emailAddress: usernameFieldController.text,
          password: passwordFieldController.text,
        );
      } on FirebaseAuthException catch (e, s) {
        if (e.code == 'user-not-found') {
          Analytics.trackEvent(eventName: 'user-not-found');
          unawaited(
            FirebaseCrashlytics.instance.recordError('Authentication with basic auth failed with exception, $e', s),
          );

          setState(() {
            usernameFieldError = true;
            loginUsernameExceptionError = 'No user found with that email.';
            loginProcessing = false;
          });

          return;
        } else if (e.code == 'wrong-password') {
          Analytics.trackEvent(eventName: 'wrong-password');
          unawaited(
            FirebaseCrashlytics.instance.recordError('Authentication with basic auth failed with exception, $e', s),
          );

          setState(() {
            passwordFieldError = true;
            loginPasswordExceptionError = 'That password wasn\'t quite right.';
            loginProcessing = false;
          });

          return;
        } else if (e.code == 'user-disabled') {
          Analytics.trackEvent(eventName: 'user-disabled');
          unawaited(
            FirebaseCrashlytics.instance.recordError('Authentication with basic auth failed with exception, $e', s),
          );

          setState(() {
            passwordFieldError = true;
            loginUsernameExceptionError = 'Your account is currently disabled.';
            loginProcessing = false;
          });

          return;
        }
      }
    }

    setState(() {
      loginUsernameExceptionError = null;
      loginPasswordExceptionError = null;
      usernameFieldError = false;
      passwordFieldError = false;
      loginProcessing = false;
    });

    debugPrint(
      'Successfully authenticated user, ${FirebaseAuth.instance.currentUser?.uid}',
    );

    Analytics.trackLogin();

    if (mounted) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const SetupRoute(),
        ),
      );
    }
  }

  /// Logs into a Firebase account using a username and password combination.
  ///
  /// Various exceptions can be thrown from the [FirebaseAuth] `signInWithEmailAndPassword` method that indicate
  /// different problems with the login. The codes from these exceptions are used to set the
  /// [loginUsernameExceptionError] and [loginPasswordExceptionError] fields. These show up in the UI the same way as
  /// form validation errors.
  Future<UserCredential?> login({required String emailAddress, required String password}) async {
    try {
      final UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login failed with exception, $e');

      rethrow;
    }
  }

  /// Validates the username field.
  String? validateUsernameField(String? value) {
    if (value == null || value.isEmpty) {
      Analytics.trackEvent(eventName: 'login_empty_username');

      setState(() {
        usernameFieldError = true;
      });

      return 'Oh no! Please enter a username.';
    } else if (!RegEx.emailAddress.hasMatch(value)) {
      Analytics.trackEvent(eventName: 'login_invalid_email_address');

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
      Analytics.trackEvent(eventName: 'login_empty_password');

      setState(() {
        passwordFieldError = true;
      });

      return 'Please enter a password.';
    } else if (value.length < 6) {
      Analytics.trackEvent(eventName: 'login_password_too_short');

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
  Future<void> onBackTap() async {
    Analytics.trackEvent(eventName: 'login_back_tap');

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const OnboardingRoute(),
      ),
    );
  }

  /// Handles taps on the Google sign in button.
  Future<void> handleGoogleLogin() async {
    try {
      final User? user = await AuthenticationService.signInWithGoogle();

      debugPrint('Successfully authenticated user, ${user?.uid}');

      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const SetupRoute(),
          ),
        );
      }
    } catch (e, s) {
      debugPrint('Failed to sign in with Google with exception, $e');

      unawaited(
        FirebaseCrashlytics.instance.recordError('Failed to sign in with Google with exception, $e', s),
      );
    }
  }

  /// Handles taps on the Apple sign in button.
  void handleAppleLogin() {
    // TODO(Toglefritz): do login with Apple, with tagging too, please
  }

  @override
  Widget build(BuildContext context) => LoginView(this);
}
