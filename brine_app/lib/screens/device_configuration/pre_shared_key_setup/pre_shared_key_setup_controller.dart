part of 'pre_shared_key_setup_route.dart';

/// Controller for the [PreSharedKeySetupRoute].
///
/// Coordinates requesting a PSK from the backend and transferring it to the Brine device over BLE.
class PreSharedKeySetupController extends State<PreSharedKeySetupRoute> {
  @override
  void initState() {
    Analytics.trackPageView('pre_shared_key_setup');

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

      // TODO(Toglefritz): Handle the failure to add the device to the account.
      rethrow;
    }
  }

  /// Requests that the Firebase backend service generate a new PSK for the Brine device and return it.
  Future<PreSharedKey> _generatePsk() {
    try {
      final User? user = widget.authSession.currentUser;

      if (user == null) {
        throw Exception('No authenticated user available for PSK generation.');
      }

      final String deviceId = widget.device.deviceId;

      final DeviceManagementService service =
          widget.deviceManagementServiceFactory?.call(user) ?? DeviceManagementService(user: user);

      return service.generatePreSharedKey(deviceId: deviceId);
    } catch (e) {
      debugPrint('Failed to get PSK with exception, $e');

      rethrow;
    }
  }

  /// Transfers the pre-shared key to the Brine device.
  Future<void> _transferPsk(PreSharedKey psk) async {
    // Register a callback to handle the response from the Brine device.
    widget.bleCommunicationManager.registerCallback(_onPskTransferCompleted);

    final Command scanCommand = Command(
      commandType: CommandType.pskTransfer,
    );
    final String commandString = scanCommand.toJsonString(
      parameters: {
        'psk': psk.value,
      },
    );

    try {
      await widget.bleCommunicationManager.writeValue(
        value: commandString,
      );
    } catch (e) {
      debugPrint('Failed to send PSK transfer command with exception, $e');

      rethrow;
    }
  }

  /// A callback that is invoked when the Brine device returns a response to the pre-shared key transfer.
  Future<void> _onPskTransferCompleted(JSON value) async {
    debugPrint('Received PSK transfer response: $value');

    final Response response = Response.fromJson(value);

    if (response.responseType == ResponseType.pskTransferred) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => WiFiSetupRoute(
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
    widget.bleCommunicationManager.unregisterCallback(_onPskTransferCompleted);

    super.dispose();
  }
}
