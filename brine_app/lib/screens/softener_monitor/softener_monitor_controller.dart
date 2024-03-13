import 'package:flutter/material.dart';

import '../../services/authentication/authentication_service.dart';
import '../authentication/onboarding/onboarding_route.dart';
import 'softener_monitor_route.dart';
import 'softener_monitor_view.dart';

/// Controller for [SoftenerMonitorRoute].
class SoftenerMonitorController extends State<SoftenerMonitorRoute> {
  /// Handles taps on the "logout" button.
  Future<void> onLogout() async {
    // TODO(Toglefritz): analytics tag

    await AuthenticationService.signOut();

    if(!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const OnboardingRoute(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SoftenerMonitorView(this);
}
