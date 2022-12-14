import 'package:brine/screens/authentication/login/login_route.dart';
import 'package:flutter/material.dart';

import 'onboarding_route.dart';
import 'onboarding_view.dart';

/// Controller for [OnboardingRoute].
class OnboardingController extends State<OnboardingRoute> {
  /// Handles taps on the login button.
  void handleLoginTap() {
    // TODO Analytics tag
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const LoginRoute(),
      ),
    );
  }

  /// Handles taps on the create an account button.
  void handleCreateAccountTap() {
    // TODO go to create account page
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
  Widget build(BuildContext context) => OnboardingView(this);
}
