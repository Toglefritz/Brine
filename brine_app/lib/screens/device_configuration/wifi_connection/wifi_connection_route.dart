import 'package:flutter/material.dart';

import '../../../services/device_management/models/brine_device.dart';
import '../../../services/ble/ble_communication_service.dart';
import 'wifi_connection_controller.dart';

/// This route accepts the SSID and password of a WiFi network to which the Brine monitor should connect and
/// sends a command to the Brine device with this information.
///
/// The Brine monitor needs to connect to WiFi to send sensor data to the cloud. This route accepts an SSID and password
/// provided by the user on a previous screen and sends a command to the Brine monitor to connect to this network. The
/// Brine monitor will attempt to connect to the network and return a response indicating the success or failure of this
/// connection attempt.
///
/// The UI for this route simply displays a loading indicator while the Brine monitor attempts to connect to the
/// network.
class WiFiConnectionRoute extends StatefulWidget {
  /// Creates and instance of [WiFiConnectionRoute].
  const WiFiConnectionRoute({
    required this.bleCommunicationManager,
    required this.ssid,
    required this.password,
    required this.device,
    super.key,
  });

  /// A [BleCommunicationService] instance that manages the communication between the app and the Brine device.
  final BleCommunicationService bleCommunicationManager;

  /// The SSID of the network to which the Brine monitor should connect. This route will send this SSID, along with
  /// the [password] to the Brine monitor. The Brine monitor will attempt to connect to this network and return a
  /// response indicating the success or failure of this connection attempt.
  final String ssid;

  /// The password of the network to which the Brine monitor should connect. This route will send this password, along
  /// with the [ssid] to the Brine monitor. The Brine monitor will attempt to connect to this network and return a
  /// response indicating the success or failure of this connection attempt.
  final String password;

  /// The Brine device that is the target of the provisioning flow.
  final BrineDevice device;

  @override
  State<WiFiConnectionRoute> createState() => WiFiConnectionController();
}
