import 'package:brine/screens/softener_monitor/softener_monitor_controller.dart';
import 'package:brine/theme/insets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/color_library.dart';
import 'components/battery_indicator.dart';
import 'components/wave_progress_indicator.dart';

/// View for [SoftenerMonitorRoute].
// TODO implement option for selecting device
class SoftenerMonitorView extends StatelessWidget {
  final SoftenerMonitorController state;

  const SoftenerMonitorView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Stack(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: Insets.medium,
                    ),
                    child: Text(
                      '${(state.widget.devices[0].saltLevel * 100).toInt()}%',
                      style: GoogleFonts.bungee().copyWith(
                        fontSize: 52,
                        color: ColorLibrary.primaryDefault,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Insets.medium,
                    ),
                    child: Text(
                      AppLocalizations.of(context).saltRemaining.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: ColorLibrary.primaryDefault,
                          ),
                      textAlign: TextAlign.center,
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
                            batteryLife: state.testProgress,//state.widget.devices[0].batteryLevel,
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
