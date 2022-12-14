import 'package:brine/models/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../values/strings.dart';
import '../components/onboarding_button.dart';
import '../onboarding/components/onboarding_legal_prompt.dart';
import 'login_controller.dart';

/// View for [LoginRoute].
class LoginView extends StatelessWidget {
  final LoginController state;

  const LoginView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(Insets.medium),
                        child: Text(
                          Strings.login,
                          style: GoogleFonts.bungee().copyWith(
                            fontSize: 42,
                            color: ColorLibrary.primaryDefault,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // TODO add username/password authentication
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Insets.small,
                        ),
                        child: OnboardingButton(
                          onPressed: state.handleGoogleLogin,
                          text: Strings.google,
                          icon: FontAwesomeIcons.google,
                        ),
                      ),
                      OnboardingButton(
                        onPressed: state.handleAppleLogin,
                        text: Strings.apple,
                        icon: FontAwesomeIcons.apple,
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
        ),
        Positioned(
          top: Insets.large,
          left: Insets.small,
          child: TextButton.icon(
            onPressed: state.handleBackTap,
            icon: const Icon(
              Icons.chevron_left,
              color: ColorLibrary.primaryDefault,
            ),
            label: Text(
              Strings.back.toUpperCase(),
              style: const TextStyle(
                color: ColorLibrary.primaryDefault,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
