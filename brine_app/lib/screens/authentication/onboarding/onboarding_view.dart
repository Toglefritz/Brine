import 'package:brine/models/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../values/image_asset.dart';
import '../../../values/strings.dart';
import '../components/onboarding_button.dart';
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
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(Insets.medium),
                    child: Text(
                      Strings.brine,
                      style: GoogleFonts.bungee().copyWith(
                        fontSize: 42,
                        color: ColorLibrary.primaryDefault,
                      ),
                    ),
                  ),
                  // TODO replace with vector
                  Image.asset(
                    ImageAsset.logoRoundMonochrome,
                    color: ColorLibrary.primaryDefault,
                    width: 150,
                    height: 150,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Insets.small,
                    ),
                    child: OnboardingButton(
                      onPressed: state.handleLoginTap,
                      text: Strings.login,
                    ),
                  ),
                  OnboardingButton(
                    onPressed: state.handleCreateAccountTap,
                    text: Strings.createAnAccount,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                Insets.medium,
              ),
              child: OnboardingLegalPrompt(
                termsOnTap: state.handleTermsAndConditionsTap,
                privacyOnTap: state.handlePrivacyPolicyTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
