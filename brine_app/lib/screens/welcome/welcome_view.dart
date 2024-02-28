import 'package:brine/components/light_button.dart';
import 'package:brine/theme/insets.dart';
import 'package:brine/screens/welcome/welcome_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/color_library.dart';
import 'components/add_device_button.dart';

/// View for [WelcomeRoute].
class WelcomeView extends StatelessWidget {
  final WelcomeController state;

  const WelcomeView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Center(
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
                    color: ColorLibrary.primaryDefault,
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
                    color: ColorLibrary.primaryDefault,
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
                        color: ColorLibrary.primaryDefault,
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
    );
  }
}
