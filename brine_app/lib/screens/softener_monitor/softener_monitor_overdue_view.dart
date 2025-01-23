import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/buttons/light_button.dart';
import '../../components/dashed_outlines/dashed_divider.dart';
import '../../theme/insets.dart';
import 'softener_monitor_controller.dart';
import 'softener_monitor_route.dart';

/// View for [SoftenerMonitorRoute] displayed when updated information from the Brine device in the Firestore database
/// is overdue.
// TODO(Toglefritz): implement option for selecting device
class SoftenerMonitorOverdueView extends StatelessWidget {
  /// Creates an instance of [SoftenerMonitorOverdueView].
  const SoftenerMonitorOverdueView(this.state, {super.key});

  /// A controller for this view.
  final SoftenerMonitorController state;

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
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * state.widget.devices[0].saltLevel),
            child: DashedDivider(
              color: Theme.of(context).primaryColorDark,
              strokeWidth: 2,
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.only(top: Insets.medium),
                      child: RichText(
                        text: TextSpan(
                          text: '${(state.widget.devices[0].saltLevel * 100).toInt()}%',
                          style: GoogleFonts.bungee().copyWith(
                            fontSize: 52,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.top,
                              child: Transform.translate(
                                offset: const Offset(0, -5),
                                child: Text(
                                  '*',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Insets.medium,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.saltRemaining.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).primaryColorDark,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (state.widget.devices[0].saltLevel <= 0.1)
                    ColoredBox(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: Insets.medium,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 64,
                          color: Colors.red[900],
                        ),
                      ),
                    ),

                  // A message about the device being overdue
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: Insets.medium,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.translate(
                                  offset: const Offset(-5, -10),
                                  child: Text(
                                    '*',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(context)!.deviceOverdueMessageDescription,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).primaryColorDark,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: Insets.medium,
                          ),
                          child: LightButton(
                            text: AppLocalizations.of(context)!.reconnect,
                            onPressed: state.onReconnectDevice,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: Insets.medium,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.deviceOverdueMessage(state.lastUpdateTime),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).primaryColorDark,
                            ),
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
