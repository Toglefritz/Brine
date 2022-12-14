import 'package:flutter/material.dart';

import 'login_route.dart';
import 'login_view.dart';

/// Controller for [LoginRoute].
class LoginController extends State<LoginRoute> {
  /// Handles taps on the back button.
  void handleBackTap() {
    Navigator.pop(context);
  }

  /// Handles taps on the Google sign in button.
  void handleGoogleLogin() {
    // TODO do login with Google
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
