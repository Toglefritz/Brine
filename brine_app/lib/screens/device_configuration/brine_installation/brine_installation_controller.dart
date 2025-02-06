import 'package:flutter/material.dart';

import '../../../services/analytics/analytics.dart';
import '../appliance_measurement/appliance_measurement_route.dart';
import 'brine_installation_route.dart';
import 'brine_installation_view.dart';

/// Controller for [BrineInstallationRoute].
class BrineInstallationController extends State<BrineInstallationRoute> {
  @override
  void initState() {
    Analytics.trackPageView('brine_installation');

    super.initState();
  }

  /// Handles taps on the button used by the user to confirm they have completed installation of the Brine device.
  Future<void> onContinue() async {
    Analytics.trackEvent(eventName: 'brine_installation_continue_tap');

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ApplianceMeasurementRoute(
          device: widget.device,
          bleCommunicationManager: widget.bleCommunicationManager,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BrineInstallationView(this);
}
