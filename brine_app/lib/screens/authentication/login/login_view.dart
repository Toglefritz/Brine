import 'package:brine/models/device.dart';
import 'package:brine/models/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/authentication_page.dart';
import '../components/dark_onboarding_button.dart';
import '../components/onboarding_button.dart';
import '../components/onboarding_field.dart';
import 'login_controller.dart';

/// View for [LoginRoute].
class LoginView extends StatelessWidget {
  final LoginController state;

  const LoginView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return AuthenticationPage(
      backOnTap: state.handleBackTap,
      content: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: Insets.large,
              ),
              child: Text(
                AppLocalizations.of(context).login,
                style: GoogleFonts.bungee().copyWith(
                  fontSize: 52,
                  color: ColorLibrary.primaryDefault,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        Form(
          key: state.loginFormKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: Insets.small),
                child: OnboardingField(
                  hint: AppLocalizations.of(context).username,
                  controller: state.usernameFieldController,
                  validator: state.validateUsernameField,
                  errorState: state.usernameFieldError,
                  additionalError: state.loginUsernameExceptionError,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: Insets.small),
                child: OnboardingField(
                  hint: AppLocalizations.of(context).password,
                  obscureText: true,
                  controller: state.passwordFieldController,
                  validator: state.validatePasswordField,
                  errorState: state.passwordFieldError,
                  additionalError: state.loginPasswordExceptionError,
                ),
              ),
              DarkOnboardingButton(
                onPressed: state.handleBasicAuthLoginSubmit,
                text: AppLocalizations.of(context).submit,
                width: 350,
                loading: state.loginProcessing,
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            vertical: Insets.large,
            horizontal: Insets.xLarge,
          ),
          child: Divider(
            thickness: 2,
            height: Insets.large,
            color: ColorLibrary.primaryDefault,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: Insets.small,
              ),
              child: OnboardingButton(
                onPressed: state.handleGoogleLogin,
                text: AppLocalizations.of(context).loginWithGoogle,
                icon: FontAwesomeIcons.google,
              ),
            ),
            if (Device.isIOS)
              OnboardingButton(
                onPressed: state.handleAppleLogin,
                text: AppLocalizations.of(context).loginWithApple,
                icon: FontAwesomeIcons.apple,
              ),
          ],
        ),
      ],
    );
  }
}
