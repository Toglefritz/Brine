import 'package:flutter/material.dart';

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
  void onContinue() {
    // TODO(Toglefritz): add analytics call

    // TODO(Toglefritz): navigate to next route
  }

  @override
  Widget build(BuildContext context) => BrineInstallationView(this);
}
