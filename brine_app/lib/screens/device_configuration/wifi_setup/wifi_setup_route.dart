/// Sends a command to the Brine monitor to have it perform a scan for available WiFi networks.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/loaders/wave_loader.dart';
import '../../../extensions/json.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/analytics/analytics.dart';
import '../../../services/ble/ble_communication_service.dart';
import '../../../services/ble/models/command.dart';
import '../../../services/ble/models/command_type.dart';
import '../../../services/device_management/models/brine_device.dart';
import '../../../theme/insets.dart';
import '../wifi_connection/wifi_connection_route.dart';

part 'wifi_setup_controller.dart';
part 'wifi_setup_view.dart';
part 'models/wifi_network.dart';

/// Sends a command to the Brine monitor to have it perform a scan for available WiFi networks. Then displays a list of
/// the detected networks to the user so they can select the network to which the Brine monitor should connect.
///
/// This route performs two tasks:
///
/// 1.  It sends a command to the Brine monitor to have it perform a scan for available WiFi networks. The Brine
/// monitor then sends the SSID and RSSI of each network to the app over Bluetooth.
/// 2.  It displays a list of the detected networks to the user so they can select the network to which the Brine
/// monitor should connect. Following the user's selection, the app collects the network's password from the user and
/// sends it to the Brine monitor.
class WiFiSetupRoute extends StatefulWidget {
  /// Creates and instance of [WiFiSetupRoute].
  const WiFiSetupRoute({
    required this.device,
    required this.bleCommunicationManager,
    super.key,
  });

  /// The [BrineDevice] that is the target of the association process.
  final BrineDevice device;

  /// A [BleCommunicationService] instance that manages the communication between the app and the Brine device.
  final BleCommunicationService bleCommunicationManager;

  @override
  State<WiFiSetupRoute> createState() => WiFiSetupController();
}
