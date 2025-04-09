import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../values/insets.dart';
import 'brine_device.dart';
import 'softener_monitor/components/battery_indicator.dart';
import 'softener_monitor/components/wave_progress_indicator.dart';

/// A preview of the Brine app, which is a water softener monitor.
// TODO(Toglefritz): implement option for selecting device
class SoftenerMonitorView extends StatelessWidget {
  /// Creates an instance of [SoftenerMonitorView].
  const SoftenerMonitorView({
    required this.device,
    super.key,
  });

  /// A controller for this view.
  final BrineDevice device;

  /// Returns a value to use for the top padding for the text element used to display the remaining level of salt in
  /// the appliance. This padding allows the text element to move down the page with the salt level indicator,
  /// stopping at a certain point representing the lowest position the text will occupy on the screen.
  EdgeInsets _getLabelTopPadding(BuildContext context) {
    // Get the level of salt in the appliance.
    final double saltLevel = device.saltLevel;

    // Get the height of the screen
    final double screenHeight = MediaQuery.of(context).size.height;

    // If the salt level is above 30%, the label will be drawn on top of the salt level indicator widget.
    if (saltLevel > 0.70) {
      // If the salt level is at 100%, a fixed top padding of Insets.medium will be used.
      final double topPadding = max(Insets.medium, screenHeight * (1 - saltLevel) - Insets.medium);

      return EdgeInsets.only(
        top: topPadding,
      );
    }
    // If the salt level is below 40%, the label will be displayed near the top of the page.
    else {
      return EdgeInsets.only(top: Insets.medium);
    }
  }

  /// Returns the text color to use for the text indicating the level of salt in the appliance. This color depends
  /// on whether or not the text is drawn on top of the salt level indicator and also on the current theme
  /// [Brightness].
  Color _getTextColor(BuildContext context) {
    // Get the level of salt in the appliance.
    final double saltLevel = device.saltLevel;

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
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFFFE0A3)
            : Theme.of(context).scaffoldBackgroundColor,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFFFE0A3)
          : Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: WaveProgressIndicator(
              progressPercent: 1 - device.saltLevel,
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
                      '${(device.saltLevel * 100).toInt()}%',
                      style: GoogleFonts.bungee().copyWith(
                        fontSize: 52,
                        color: _getTextColor(context),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
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
                  if (device.saltLevel <= 0.1)
                    Padding(
                      padding: EdgeInsets.only(
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
                          padding: EdgeInsets.only(
                            top: Insets.xSmall,
                            bottom: Insets.medium,
                          ),
                          child: BatteryIndicator(
                            batteryLife: device.batteryLevel,
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
