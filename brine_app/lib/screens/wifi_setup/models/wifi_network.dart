import '../wifi_setup_route.dart';

/// Represents a WiFi network detected by the Brine device, information about which is sent to the app by the
/// Brine device over Bluetooth.
///
/// This class is used in the [WiFiSetupRoute] to display a list of WiFi networks detected by the Brine device. The
/// device sends the SSID and RSSI of each network to the app. This enables the app to display a list of networks
/// to the user, who can then select the network to which the Brine device should connect. Following the user's
/// selection, the app collects the network's password from the user and sends it to the Brine device.
class WifiNetwork {
  final String ssid;
  final String rssi;

  WifiNetwork({
    required this.ssid,
    required this.rssi,
  });
}
