import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../services/device_management/device_management_service.dart';
import '../wifi_setup/wifi_setup_route.dart';
import 'association_route.dart';
import 'association_view.dart';

/// Controller for the [AssociationRoute].
class AssociationController extends State<AssociationRoute> {
  @override
  void initState() {
    // Associate the Brine device to the user's account.
    WidgetsBinding.instance.addPostFrameCallback((_) => _associateDevice());

    super.initState();
  }

  /// Attempt to associate the Brine device with the user's account.
  Future<void> _associateDevice() async {
    try {
      // Get the current user.
      final User user = FirebaseAuth.instance.currentUser!;

      // Add the device to the user's account.
      await DeviceManagementService(user: user).addDeviceToAccount(
        device: widget.device,
      );
    } catch (e) {
      debugPrint('Failed to associate device with exception, $e');

      // TODO(Toglefritz): Handle the failure to add the device to the account.
    }

    // With the device successfully associated, navigate to the next screen.
    if (!mounted) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => WiFiSetupRoute(
          bleCommunicationManager: widget.bleCommunicationManager,
          device: widget.device,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AssociationView(this);
}
