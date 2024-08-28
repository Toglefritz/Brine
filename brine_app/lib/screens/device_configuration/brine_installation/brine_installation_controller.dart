import 'package:flutter/material.dart';

import '../appliance_measurement/appliance_measurement_route.dart';
import 'brine_installation_route.dart';
import 'brine_installation_view.dart';

/// Controller for [BrineInstallationRoute].
class BrineInstallationController extends State<BrineInstallationRoute> {
  @override
  void initState() {
    // TODO(Toglefritz): add analytics call

    super.initState();
  }

  /// Handles taps on the button used by the user to confirm they have completed installation of the Brine device.
  Future<void> onContinue() async {
    // TODO(Toglefritz): add analytics call

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
