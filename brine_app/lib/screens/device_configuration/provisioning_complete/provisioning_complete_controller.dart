part of 'provisioning_complete_route.dart';

/// Controller for [ProvisioningCompleteRoute].
class ProvisioningCompleteController extends State<ProvisioningCompleteRoute> {
  /// Determines if the command to complete the provisioning process has been sent to the Brine device and the device
  /// has responded with a success message.
  bool _isProvisioningComplete = false;

  @override
  void initState() {
    Analytics.trackPageView('provisioning_complete');

    // Complete the provisioning process.
    unawaited(_completeProvisioning());

    super.initState();
  }

  /// Sends a command to the Brine device to complete the provisioning process. This will cause the device to upload its
  /// battery and salt level readings to the cloud backend before discontinuing Bluetooth communication.
  Future<void> _completeProvisioning() async {
    // Register a callback to handle the response from the Brine device.
    widget.bleCommunicationManager.registerCallback(_onProvisioningComplete);

    // Send a command to the Brine device to complete the provisioning process.
    final Command connectCommand = Command(
      commandType: CommandType.completeProvisioning,
    );
    final String commandString = connectCommand.toJsonString();

    try {
      await widget.bleCommunicationManager.writeValue(
        value: commandString,
      );
    } catch (e) {
      debugPrint('Failed to send provisioning complete command with exception, $e');

      // TODO(Toglefritz): Handle the failure to send the provisioning complete command.
    }
  }

  /// A callback that is invoked when the Brine device returns a response to the "complete_provisioning" command.
  ///
  /// The Brine device can send a response indicating the success or failure of the attempt to conclude the provisioning
  /// process. Each of these responses will contain a different value for the "response" key. For successful
  /// connections, the value will be a JSON object with a format like the following:
  ///
  /// ```json
  /// {
  /// "response": "provisioning_complete",
  /// }
  /// ```
  ///
  /// If the Brine device fails to finish the provisioning process, which is most likely due to a failure to upload the
  /// battery and salt levels, it will send a dedicated error type that contains a message indicating the reason for the
  /// failure. The format of this error response is as follows:
  ///
  /// ```json
  /// {
  /// "response": "complete_provisioning_error",
  /// "message": "<error message>"
  /// }
  /// ```
  Future<void> _onProvisioningComplete(JSON value) async {
    debugPrint('Provisioning complete response: $value');

    // Get a Response object from the JSON response.
    final Response response = Response.fromJson(value);

    // If the response indicates that the Brine device successfully completed the provisioning process, update the UI to
    // reflect this.
    if (response.responseType == ResponseType.provisioningComplete) {
      // Terminate the Bluetooth connection.
      widget.bleCommunicationManager.dispose();

      setState(() {
        _isProvisioningComplete = true;
      });
    }
    // If the response indicates that there was an error while attempting to complete the provisioning process, log the
    // error message.
    else {
      debugPrint('Provisioning completion failed with message: ${value['message']}');

      // TODO(Toglefritz): Handle the failure to connect to complete the provisioning process.
    }
  }

  /// Handles taps on the "Done" button after the user has been presented with the interface confirming that the setup
  /// process for their Brine monitor is complete.
  Future<void> onContinue() async {
    // Navigate to the SetupRoute to refresh the user's account information.
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const SetupRoute(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      _isProvisioningComplete ? ProvisioningCompleteView(this) : ProvisioningCompleteViewLoading(this);
}
