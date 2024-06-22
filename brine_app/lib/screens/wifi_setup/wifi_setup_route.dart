import 'package:flutter/material.dart';

import '../../services/ble/ble_communication_manager.dart';
import 'wifi_setup_controller.dart';

/// Sends a command to the Brine monitor to have it perform a scan for available WiFi networks. Then displays a list of
/// the detected networks to the user so they can select the network to which the Brine monitor should connect.
///
/// This route performs two tasks:
///
///   1.  It sends a command to the Brine monitor to have it perform a scan for available WiFi networks. The Brine
///       monitor then sends the SSID and RSSI of each network to the app over Bluetooth.
///   2.  It displays a list of the detected networks to the user so they can select the network to which the Brine
///       monitor should connect. Following the user's selection, the app collects the network's password from the user
///       and sends it to the Brine monitor.
class WiFiSetupRoute extends StatefulWidget {
  /// Creates and instance of [WiFiSetupRoute].
  const WiFiSetupRoute({
    required this.bleCommunicationManager,
    super.key,
  });

  /// A [BleCommunicationManager] instance that manages the communication between the app and the Brine device.
  final BleCommunicationManager bleCommunicationManager;

  @override
  State<WiFiSetupRoute> createState() => WiFiSetupController();
}
