import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../extensions/json.dart';
import '../../../services/analytics/analytics.dart';
import '../../../services/ble/models/command.dart';
import '../../../services/ble/models/command_type.dart';
import '../../../services/ble/models/response.dart';
import '../../../services/ble/models/response_type.dart';
import '../../../services/device_management/device_management_service.dart';
import '../../../services/device_management/models/pre_shared_key.dart';
import '../wifi_setup/wifi_setup_route.dart';
import 'pre_shared_key_setup_route.dart';
import 'pre_shared_key_setup_view.dart';

/// Controller for the [PreSharedKeySetupRoute].
class PreSharedKeySetupController extends State<PreSharedKeySetupRoute> {
  @override
  void initState() {
    Analytics.trackPageView('pre_shared_key_setup');

    // Associate the Brine device to the user's account.
    WidgetsBinding.instance.addPostFrameCallback((_) => _performPskSetup());

    super.initState();
  }

  /// Performs the following steps related to the pre-shared key for the Brine device:
  ///
  /// 1. Request a PSK from the Firebase backend system.
  /// 2. Transfers the PSK to the Brine device.
  Future<void> _performPskSetup() async {
    try {
      // Request a PSK from the backend.
      final PreSharedKey psk = await _generatePsk();

      // Transfer the PSK to the Brine device.
      _transferPsk(psk);
    } catch (e) {
      debugPrint('Failed to perform PSK setup with exception, $e');

      // TODO(Toglefritz): Handle the failure to add the device to the account.
      rethrow;
    }
  }

  /// Requests that the Firebase backend service generate a new PSK for the Brine device and return it.
  ///
  /// When the Firebase backend generates a new PSK, the controller for the endpoint called by this function also
  /// handles storing the PSK in the database in association with the device ID. Once the PSK has been created and
  /// stored, the PSK is returned to this function.
  Future<PreSharedKey> _generatePsk() {
    try {
      // Get the current user.
      final User user = FirebaseAuth.instance.currentUser!;

      // Get the device ID.
      final String deviceId = widget.device.deviceId;

      // Request a PSK from the backend.
      return DeviceManagementService(user: user).generatePreSharedKey(deviceId: deviceId);
    } catch (e) {
      debugPrint('Failed to get PSK with exception, $e');

      // TODO(Toglefritz): Handle the failure to add the device to the account.
      rethrow;
    }
  }

  /// Transfers the pre-shared key to the Brine device.
  ///
  /// The mobile app does not hold the PSK for the Brine device except in this controller. Once the navigation call
  /// made in response to receiving confirmation of the PSK transfer is made, the PSK is no longer stored in the app.
  /// From that point forward, the PSK is only used for securing communication between the Brine device and the Firebase
  /// backend.
  void _transferPsk(PreSharedKey psk) {
    // Register a callback to handle the response from the Brine device.
    widget.bleCommunicationManager.registerCallback(_onPskTransferCompleted);

    // Send a command to the Brine device to scan for available WiFi networks.
    final Command scanCommand = Command(
      commandType: CommandType.pskTransfer,
    );
    final String commandString = scanCommand.toJsonString(
      parameters: {
        'psk': psk.value,
      },
    );

    try {
      widget.bleCommunicationManager.writeValue(
        value: commandString,
      );
    } catch (e) {
      debugPrint('Failed to send PSK transfer command with exception, $e');

      rethrow;
    }
  }

  /// A callback that is invoked when the Brine device returns a response to the pre-shared key transfer.
  ///
  /// Assuming the PSK transfer is successful, the app will navigate to the next screen in the device configuration
  void _onPskTransferCompleted(JSON value) {
    debugPrint('Received PSK transfer response: $value');

    // Get a Response object from the JSON response.
    final Response response = Response.fromJson(value);

    // If the response indicates that the PSK was successfully transferred, navigate to the next screen.
    if (response.responseType == ResponseType.pskTransferred) {
      // Navigate to the next screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => WiFiSetupRoute(
            bleCommunicationManager: widget.bleCommunicationManager,
            device: widget.device,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => const PreSharedKeySetupView();

  @override
  void dispose() {
    // Unregister the callback for changes in the value of the characteristic.
    widget.bleCommunicationManager.unregisterCallback(_onPskTransferCompleted);

    super.dispose();
  }
}
