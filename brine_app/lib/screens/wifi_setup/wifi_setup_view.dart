import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/insets.dart';
import 'models/wifi_network.dart';
import 'wifi_setup_controller.dart';
import 'wifi_setup_route.dart';

/// View for [WiFiSetupRoute].
class WiFiSetupView extends StatelessWidget {
  /// Creates an instance of [WiFiSetupView].
  const WiFiSetupView(this.state, {super.key});

  /// A controller for this view.
  final WiFiSetupController state;

  /// Returns an [Icon] to visually represent the signal strength of a WiFi network.
  Icon _getIconForSignalStrength(int rssi) {
    if (rssi >= -60) {
      return const Icon(Icons.signal_wifi_4_bar, color: Colors.green);
    } else if (rssi >= -70) {
      return const Icon(Icons.network_wifi_3_bar, color: Colors.yellow);
    } else if (rssi >= -80) {
      return const Icon(Icons.network_wifi_2_bar, color: Colors.orange);
    } else if (rssi >= -90) {
      return const Icon(Icons.network_wifi_1_bar, color: Colors.red);
    } else {
      return const Icon(Icons.signal_wifi_0_bar, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Insets.medium,
          ),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Insets.small,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    AppLocalizations.of(context)!.wifiSetup,
                    style: GoogleFonts.bungee().copyWith(
                      fontSize: 52,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  vertical: Insets.small,
                  horizontal: Insets.medium,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    AppLocalizations.of(context)!.wifiSetupInstructions,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).primaryColorDark,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // If the networks list is still loading, display a loading indicator.
              if (state.networks == null)
                SliverFillRemaining(
                  child: Center(
                    child: SpinKitWave(
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              // If networks are detected, display a list of them.
              if (state.networks != null && state.networks!.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.large,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final WiFiNetwork network = state.networks![index];

                        return ListTile(
                          title: Text(network.ssid),
                          trailing: _getIconForSignalStrength(network.rssi),
                        );
                      },
                      childCount: state.networks!.length,
                    ),
                  ),
                ),
              // If no networks are detected, display a message to the user.
              if (state.networks != null && state.networks!.isEmpty)
                SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.signal_wifi_off),
                      Text(
                        AppLocalizations.of(context)!.noNetworksDetected,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).primaryColorDark,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
