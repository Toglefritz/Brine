import 'package:flutter/material.dart';

import '../../services/device_management/device_management_service.dart';
import 'association_route.dart';
import 'association_view.dart';

/// Controller for the [AssociationRoute].
class AssociationController extends State<AssociationRoute> {
  @override
  void initState() {
    // Associate the Brine device to the user's account.
    _associateDevice();

    super.initState();
  }

  /// Attempt to associate the Brine device with the user's account.
  void _associateDevice() {
    try {
      DeviceManagementService.addDeviceToAccount(
        deviceId: widget.deviceId,
        deviceName: widget.deviceName,
      );
    } catch (e) {
      debugPrint('Failed to associate device with exception, $e');

      // TODO(Toglefritz): Handle the failure to add the device to the account.
    }
  }

  @override
  Widget build(BuildContext context) => AssociationView(this);
}
