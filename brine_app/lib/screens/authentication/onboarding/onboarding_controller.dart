import 'package:brine/screens/authentication/login/login_route.dart';
import 'package:flutter/material.dart';

import '../create_account/create_account_route.dart';
import 'onboarding_route.dart';
import 'onboarding_view.dart';

/// Controller for [OnboardingRoute].
class OnboardingController extends State<OnboardingRoute> {
  /// Handles taps on the login button.
  void handleLoginTap() {
    // TODO Analytics tag
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const LoginRoute(),
      ),
    );
  }

  /// Handles taps on the create an account button.
  void handleCreateAccountTap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const CreateAccountRoute(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => OnboardingView(this);
}
