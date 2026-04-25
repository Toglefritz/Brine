import '../../../../extensions/json.dart';
import '../wifi_setup_route.dart';

/// Represents a WiFi network detected by the Brine device, information about which is sent to the app by the Brine
/// device over Bluetooth.
///
/// This class is used in the [WiFiSetupRoute] to display a list of WiFi networks detected by the Brine device. The
/// device sends the SSID and RSSI of each network to the app. This enables the app to display a list of networks to the
/// user, who can then select the network to which the Brine device should connect. Following the user's selection, the
/// app collects the network's password from the user and sends it to the Brine device.
class WiFiNetwork {
  /// Creates an instance of [WiFiNetwork].
  WiFiNetwork({
    required this.ssid,
    required this.rssi,
  });

  /// Creates an instance of [WiFiNetwork] from a JSON object.
  factory WiFiNetwork.fromJson(JSON json) => WiFiNetwork(
    ssid: json['ssid'] as String,
    rssi: json['rssi'] as int,
  );

  /// The SSID of the WiFi network.
  final String ssid;

  /// The received signal strength indicator (RSSI) of the WiFi network. A value closer to 0 indicates a stronger
  /// signal. A value closer to -100 indicates a weaker signal. The app considers a signal with an RSSI of -20dBm or
  /// higher to be strong.
  final int rssi;
}
