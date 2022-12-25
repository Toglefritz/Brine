import 'package:brine/screens/authentication/onboarding/onboarding_route.dart';
import 'package:flutter/material.dart';

import 'create_account_route.dart';
import 'create_account_view.dart';

/// Controller for [CreateAccountRoute].
class CreateAccountController extends State<CreateAccountRoute> {
  /// A key used for the username and password login form.
  final createAccountFormKey = GlobalKey<FormState>();

  /// Handles submission of the username and password to perform basic authentication against Firebase.
  void handleCreateAccountSubmit() {
    if (createAccountFormKey.currentState!.validate()) {
      // TODO perform basic auth
    }
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
  Future<void> handleGoogleCreateAccount() async {
    // TODO create account with Google
  }

  /// Handles taps on the Apple sign in button.
  Future<void> handleAppleCreateAccount() async {
    // TODO create account with Apple
  }

  @override
  Widget build(BuildContext context) => CreateAccountView(this);
}
