import 'package:flutter/material.dart';

import '../../../extensions/json.dart';
import '../../../services/analytics/analytics.dart';
import '../../../services/ble/models/command.dart';
import '../../../services/ble/models/command_type.dart';
import '../../../services/ble/models/response.dart';
import '../../../services/ble/models/response_type.dart';
import '../brine_installation/brine_installation_route.dart';
import 'wifi_connection_route.dart';
import 'wifi_connection_view.dart';

/// Controller for [WiFiConnectionRoute].
class WiFiConnectionController extends State<WiFiConnectionRoute> {
  @override
  void initState() {
    Analytics.trackPageView('wifi_connection');

    // Send a command to the Brine device to provide the SSID and password of the WiFi network to which the Brine device
    // should connect. This is done after the build method is complete because the view will be rebuilt after a response
    // is received.
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendWiFiConnectCommand());

    super.initState();
  }

  /// Sends a command to the Brine device to connect to a WiFi network. The SSID and password of the network are
  /// provided by the user on the previous screen.
  void _sendWiFiConnectCommand() {
    debugPrint('Sending WiFi connect command for SSID, ${widget.ssid}');

    // Register a callback to handle the response from the Brine device.
    widget.bleCommunicationManager.registerCallback(_onWiFiConnectCompleted);

    // Send a command to the Brine device to connect to the selected WiFi network.
    final Command connectCommand = Command(
      commandType: CommandType.wifiConnect,
    );
    final String commandString = connectCommand.toJsonString(
      parameters: {
        'ssid': widget.ssid,
        'password': widget.password,
      },
    );

    try {
      widget.bleCommunicationManager.writeValue(
        value: commandString,
      );
    } catch (e) {
      debugPrint('Failed to send connect command with exception, $e');

      // TODO(Toglefritz): Handle the failure to send the connect command.
    }
  }

  /// A callback that is invoked when the Brine device returns a response to the "wifi_connect" command.
  ///
  /// The Brine device can send a response indicating the success or failure of the connection attempt. Each of these
  /// responses will contain a different value for the "response" key. For successful connections, the value will be
  /// a JSON object with a format like the following:
  ///
  /// ```json
  /// {
  ///    "response": "wifi_connected",
  ///    "ssid": "<SSID>"
  /// }
  /// ```
  ///
  /// If the Brine device fails to connect to the network, it will send a dedicated error type that contains a message
  /// indicating the reason for the failure. The format of this error response is as follows:
  ///
  /// ```json
  /// {
  ///   "response": "wifi_connect_failed",
  ///   "message": "<error message>"
  /// }
  /// ```
  Future<void> _onWiFiConnectCompleted(JSON value) async {
    debugPrint('WiFi connect response: $value');

    // Get a Response object from the JSON response.
    final Response response = Response.fromJson(value);

    // If the response indicates that the Brine device successfully connected to the WiFi network, navigate to the
    // Brine installation screen.
    if (response.responseType == ResponseType.wifiConnected) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => BrineInstallationRoute(
            bleCommunicationManager: widget.bleCommunicationManager,
            device: widget.device,
          ),
        ),
      );
    }
    // If the response indicates that the Brine device failed to connect to the WiFi network, display an error message
    // to the user.
    else {
      debugPrint('WiFi connection failed with message: ${value['message']}');

      // TODO(Toglefritz): Handle the failure to connect to the WiFi network.
    }
  }

  @override
  Widget build(BuildContext context) => WiFiConnectionView(this);

  @override
  void dispose() {
    // Unregister the callback for changes in the value of the characteristic.
    widget.bleCommunicationManager.unregisterCallback(_onWiFiConnectCompleted);

    super.dispose();
  }
}
