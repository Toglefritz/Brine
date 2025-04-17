import 'package:flutter/material.dart';

import '../../services/analytics/analytics.dart';
import '../../services/authentication/authentication_service.dart';
import '../authentication/onboarding/onboarding_route.dart';
import 'error_route.dart';
import 'error_view.dart';

/// Controller for the [ErrorRoute].
class ErrorController extends State<ErrorRoute> {
  @override
  void initState() {
    Analytics.trackPageView('error');

    super.initState();
  }

  /// Handles taps on the button used to log into the Brine app again following an authentication error.
  Future<void> onLoginAgain() async {
    // First ensure that the current session is disposed.
    await AuthenticationService.signOut();

    // Navigate to the onboarding route.
    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const OnboardingRoute(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ErrorView(this);
}
