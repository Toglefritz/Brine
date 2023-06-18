import 'package:brine/theme/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../values/image_asset.dart';
import '../../../components/light_button.dart';
import 'components/onboarding_legal_prompt.dart';
import 'onboarding_controller.dart';

/// View for [OnboardingRoute].
class OnboardingView extends StatelessWidget {
  final OnboardingController state;

  const OnboardingView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: Insets.xxLarge,
                      bottom: Insets.large,
                    ),
                    child: Text(
                      AppLocalizations.of(context).brine,
                      style: GoogleFonts.bungee().copyWith(
                        fontSize: 52,
                        color: ColorLibrary.primaryDefault,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // TODO replace with vector
                  Image.asset(
                    ImageAsset.logoTransparentBackground,
                    width: 200,
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: Insets.xLarge,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Insets.small,
                        ),
                        child: LightButton(
                          onPressed: state.handleLoginTap,
                          text: AppLocalizations.of(context).login,
                        ),
                      ),
                      LightButton(
                        onPressed: state.handleCreateAccountTap,
                        text: AppLocalizations.of(context).createAnAccount,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(Insets.medium),
                child: OnboardingLegalPrompt(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
