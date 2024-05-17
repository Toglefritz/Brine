import 'package:flutter/material.dart';

import '../../services/analytics/analytics.dart';
import '../../services/authentication/authentication_service.dart';
import '../authentication/onboarding/onboarding_route.dart';
import '../scan/scan_route.dart';
import 'components/add_device_button.dart';
import 'welcome_route.dart';
import 'welcome_view.dart';

/// Controller for [WelcomeRoute].
class WelcomeController extends State<WelcomeRoute> {
  /// A [FocusNode] for the menu button.
  final FocusNode buttonFocusNode = FocusNode(debugLabel: 'Menu Button');

  /// Handles taps on the [AddDeviceButton] button located on the [WelcomeView].
  Future<void> onAddDevicePressed() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ScanRoute(),
      ),
    );
  }

  /// Handles taps on the button allowing a user to order Brine.
  void onOrderButtonPressed() {
    Analytics.trackEvent(eventName: 'order_brine_tap');

    // TODO(Toglefritz): implementation
  }

  /// Handles taps on the "logout" button.
  Future<void> onLogout() async {
    Analytics.trackEvent(eventName: 'logout_tap');

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
  Widget build(BuildContext context) => WelcomeView(this);
}
