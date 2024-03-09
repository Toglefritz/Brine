import 'package:flutter/material.dart';

import '../create_account/create_account_route.dart';
import '../login/login_route.dart';
import 'onboarding_route.dart';
import 'onboarding_view.dart';

/// Controller for [OnboardingRoute].
class OnboardingController extends State<OnboardingRoute> {
  /// Handles taps on the login button.
  void handleLoginTap() {
    // TODO(Toglefritz): Analytics tag

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const LoginRoute(),
      ),
    );
  }

  /// Handles taps on the create an account button.
  void handleCreateAccountTap() {
    // TODO(Toglefritz): Analytics tag

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const CreateAccountRoute(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => OnboardingView(this);
}
