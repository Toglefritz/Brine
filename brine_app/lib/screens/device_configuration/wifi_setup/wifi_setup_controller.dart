import 'package:flutter/material.dart';

import '../../../extensions/json.dart';
import '../../../services/ble/models/command.dart';
import '../../../services/ble/models/command_type.dart';
import '../wifi_connection/wifi_connection_route.dart';
import 'models/wifi_network.dart';
import 'wifi_setup_route.dart';
import 'wifi_setup_view.dart';

/// Controller for [WiFiSetupRoute].
class WiFiSetupController extends State<WiFiSetupRoute> {
  /// A list of WiFi networks detected by the Brine device.
  List<WiFiNetwork>? networks;

  /// A collective controller for all of the WiFi network password fields. Since only one password can be submitted,
  /// this controller is used across all of the password fields.
  final TextEditingController passwordFieldController = TextEditingController();

  /// The index of the currently expanded [ExpansionPanel]. If no panel is expanded, this value is -1.
  int expandedIndex = -1;

  @override
  void initState() {
    // Send a command to the Brine device to scan for available WiFi networks. This is done after the build method is
    // complete because the view will be rebuilt after the command is sent and the response is received.
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendScanCommand());

    super.initState();
  }

  /// Sends a command to the Brine device to scan for available WiFi networks and return the list of networks
  /// to the app.
  ///
  /// This function performs two tasks:
  ///   1. It establishes a callback to handle the response from the Brine device. This is done before sending the
  ///      command so that this controller is prepared to handle the response when it arrives.
  ///   2. It sends a command to the Brine device to scan for available WiFi networks.
  void _sendScanCommand() {
    // Register a callback to handle the response from the Brine device.
    widget.bleCommunicationManager.registerCallback(_onScanCompleted);

    // Send a command to the Brine device to scan for available WiFi networks.
    final Command scanCommand = Command(
      commandType: CommandType.scan,
    );
    final String commandString = scanCommand.toJsonString();

    try {
      widget.bleCommunicationManager.writeValue(
        value: commandString,
      );
    } catch (e) {
      debugPrint('Failed to send scan command with exception, $e');

      // TODO(Toglefritz): Handle the failure to send the scan command.
    }
  }

  /// A callback that is invoked when the Brine device returns a list of WiFi networks in response to the "scan"
  /// command.
  void _onScanCompleted(JSON value) {
    debugPrint('Received WiFi networks list: $value}');

    // Parse the list of networks from the JSON object to a list of WiFiNetwork objects.
    final List<dynamic> networkList = value['networks'] as List<dynamic>;

    setState(() {
      networks = networkList
          .map((dynamic network) => WiFiNetwork.fromJson(network as JSON))
          .toList();
    });
  }

  /// Handles taps on the network [ExpansionPanel]s to expand or collapse them.
  void onExpansionPanelToggled({required int index, required bool isExpanded}) {
    if (isExpanded) {
      setState(() {
        expandedIndex = index;
      });
    } else {
      setState(() {
        expandedIndex = -1;
      });
    }
  }

  /// Handles submission of the password for a WiFi network selected from the list of networks.
  ///
  /// This function simply navigates to the next screen in the setup process, providing the SSID and password for the
  /// selected network to the next screen.
  Future<void> onConnectToNetwork(WiFiNetwork network) async {
    // Get the SSID of the selected network.
    final String ssid = network.ssid;

    // Get the password from the password field controller.
    final String password = passwordFieldController.text;

    // Navigate to the WiFi connection screen, providing the SSID and password of the selected network.
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => WiFiConnectionRoute(
          bleCommunicationManager: widget.bleCommunicationManager,
          ssid: ssid,
          password: password,
          device: widget.device,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => WiFiSetupView(this);

  @override
  void dispose() {
    // Unregister the callback for changes in the value of the characteristic.
    widget.bleCommunicationManager.unregisterCallback(_onScanCompleted);

    super.dispose();
  }
}
