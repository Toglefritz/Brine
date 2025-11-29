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
      await _transferPsk(psk);
    } catch (e) {
      debugPrint('Failed to perform PSK setup with exception, $e');

      // TODO(Toglefritz): Handle the failure.
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

      // TODO(Toglefritz): Handle the failure.
      rethrow;
    }
  }

  /// Transfers the pre-shared key to the Brine device in chunks.
  ///
  /// The PSK is sent in multiple small chunks to avoid BLE stack overflow on the device.
  /// Each chunk is 16 characters, which keeps the BLE payload small and prevents crashes.
  ///
  /// The mobile app does not hold the PSK for the Brine device except in this controller. Once the navigation call made
  /// in response to receiving confirmation of the PSK transfer is made, the PSK is no longer stored in the app. From
  /// that point forward, the PSK is only used for securing communication between the Brine device and the Firebase
  /// backend.
  Future<void> _transferPsk(PreSharedKey psk) async {
    // Register a callback to handle the response from the Brine device.
    widget.bleCommunicationManager.registerCallback(_onPskChunkResponse);

    const int chunkSize = 16; // Send 16 characters at a time
    final String pskValue = psk.value;
    final int totalChunks = (pskValue.length / chunkSize).ceil();

    debugPrint('Transferring PSK in $totalChunks chunks (no intermediate responses)');

    try {
      // Send each chunk without waiting for intermediate responses
      for (int i = 0; i < totalChunks; i++) {
        final int start = i * chunkSize;
        final int end = (start + chunkSize < pskValue.length) ? start + chunkSize : pskValue.length;
        final String chunk = pskValue.substring(start, end);

        debugPrint('Sending chunk ${i + 1}/$totalChunks');

        final Command chunkCommand = Command(commandType: CommandType.pskChunk);
        final String commandString = chunkCommand.toJsonString(
          parameters: {'chunk': chunk, 'index': i, 'total': totalChunks},
        );

        await widget.bleCommunicationManager.writeValue(value: commandString);

        // Add a small delay between chunks to ensure they're processed in order
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }

      debugPrint('All chunks sent, waiting for final response...');
    } catch (e) {
      debugPrint('Failed to send PSK chunk with exception, $e');

      rethrow;
    }
  }

  /// A callback that is invoked when the Brine device returns a response after PSK transfer.
  ///
  /// Only the final chunk receives a response (after the PSK is saved).
  /// Intermediate chunks do not send responses to minimize stack usage on the device.
  void _onPskChunkResponse(JSON value) {
    debugPrint('Received PSK response: $value');

    // Get a Response object from the JSON response.
    final Response response = Response.fromJson(value);

    // The response should be psk_saved (intermediate chunks don't send responses)
    if (response.responseType == ResponseType.pskTransferred) {
      debugPrint('PSK saved successfully, navigating to WiFi setup');

      // Unregister the callback before navigating
      widget.bleCommunicationManager.unregisterCallback(_onPskChunkResponse);

      // Navigate to the next screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) =>
              WiFiSetupRoute(bleCommunicationManager: widget.bleCommunicationManager, device: widget.device),
        ),
      );
    } else {
      debugPrint('Unexpected response type: ${response.responseType}');
    }
  }

  @override
  Widget build(BuildContext context) => const PreSharedKeySetupView();

  @override
  void dispose() {
    // Unregister the callback for changes in the value of the characteristic.
    widget.bleCommunicationManager.unregisterCallback(_onPskChunkResponse);

    super.dispose();
  }
}
