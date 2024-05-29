import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/insets.dart';
import 'components/battery_indicator.dart';
import 'components/wave_progress_indicator.dart';
import 'softener_monitor_controller.dart';
import 'softener_monitor_route.dart';

/// View for [SoftenerMonitorRoute].
// TODO(Toglefritz): implement option for selecting device
class SoftenerMonitorView extends StatelessWidget {
  /// Creates an instance of [SoftenerMonitorView].
  const SoftenerMonitorView(this.state, {super.key});

  /// A controller for this view.
  final SoftenerMonitorController state;

  /// Returns a value to use for the top padding for the text element used to display the remaining level of salt in
  /// the appliance. This padding allows the text element to move down the page with the salt level indicator,
  /// stopping at a certain point representing the lowest position the text will occupy on the screen.
  EdgeInsets _getLabelTopPadding(BuildContext context) {
    // Get the level of salt in the appliance.
    final double saltLevel = state.widget.devices[0].saltLevel;

    // Get the height of the screen
    final screenHeight = MediaQuery.of(context).size.height;

    // If the salt level is above 40%, the label will follow the salt level indicator down the screen.
    if (saltLevel > 0.70) {
      return EdgeInsets.only(top: screenHeight * (1 - saltLevel) - Insets.medium);
    }
    // If the salt level is below 40%, the label will be displayed near the top of the page.
    else {
      return const EdgeInsets.only(top: Insets.medium);
    }
  }

  /// Returns the text color to use for the text indicating the level of salt in the appliance. This color depends
  /// on whether or not the text is drawn on top of the salt level indicator and also on the current theme
  /// [Brightness].
  Color _getTextColor(BuildContext context) {
    // Get the level of salt in the appliance.
    final double saltLevel = state.widget.devices[0].saltLevel;

    // If the salt level is above 70%, the label will be drawn on top of the salt level indicator widget.
    if (saltLevel > 0.70) {
      return const Color(0xFF212121);
    }
    // If the salt level is below 70%, the label will be displayed near the top of the screen, on the
    // Scaffold background color. If using a dark Brightness, the label text should be lightly colored.
    else {
      return Theme.of(context).primaryColorDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFFFE0A3)
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => state.onLogout(),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: AppLocalizations.of(context)!.logout,
                  child: Text(
                    AppLocalizations.of(context)!.logout,
                    textAlign: TextAlign.center,
                  ),
                ),
              ];
            },
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: WaveProgressIndicator(
              progressPercent: 1 - state.widget.devices[0].saltLevel,
              fillColor: Theme.of(context).primaryColor,
              // Defaults to 0.5.
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: _getLabelTopPadding(context),
                    child: Text(
                      '${(state.widget.devices[0].saltLevel * 100).toInt()}%',
                      style: GoogleFonts.bungee().copyWith(
                        fontSize: 52,
                        color: _getTextColor(context),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Insets.medium,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.saltRemaining.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: _getTextColor(context),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (state.widget.devices[0].saltLevel <= 0.1)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: Insets.medium,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 64,
                        color: Colors.red[900],
                      ),
                    ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: Insets.xSmall,
                            bottom: Insets.medium,
                          ),
                          child: BatteryIndicator(
                            batteryLife: state.widget.devices[0].batteryLevel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
