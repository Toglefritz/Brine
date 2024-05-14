import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/light_button.dart';
import '../../theme/insets.dart';
import 'components/add_device_button.dart';
import 'welcome_controller.dart';
import 'welcome_route.dart';

/// View for [WelcomeRoute].
class WelcomeView extends StatelessWidget {
  /// Creates an instance of [WelcomeView].
  const WelcomeView(this.state, {super.key});

  /// A controller for this view.
  final WelcomeController state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).primaryColor
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).primaryColor
            : Theme.of(context).scaffoldBackgroundColor,
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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Insets.medium,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.medium,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.addADevice,
                    style: GoogleFonts.bungee().copyWith(
                      fontSize: 52,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Insets.large,
                    horizontal: Insets.xLarge,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.addDeviceInvitation,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).primaryColorDark,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: Insets.medium),
                  child: AddDeviceButton(
                    onPressed: state.onAddDevicePressed,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.salesPrompt,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).primaryColorDark,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: Insets.xSmall,
                          bottom: Insets.medium,
                        ),
                        child: LightButton(
                          text: AppLocalizations.of(context)!.getOneNow,
                          onPressed: state.onOrderButtonPressed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
