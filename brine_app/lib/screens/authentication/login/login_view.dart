import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/buttons/light_button.dart';
import '../../../extensions/brightness_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/device.dart';
import '../../../theme/insets.dart';
import '../../../values/image_asset.dart';
import '../components/authentication_page.dart';
import '../components/dark_onboarding_button.dart';
import '../components/onboarding_field.dart';
import 'login_controller.dart';
import 'login_route.dart';

/// View for [LoginRoute].
class LoginView extends StatelessWidget {
  /// Creates an instance of [LoginView].
  const LoginView(this.state, {super.key});

  /// A controller for this view.
  final LoginController state;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      Theme.of(context).brightness.oppositeSystemOverlayStyle(),
    );

    return AuthenticationPage(
      backOnTap: state.onBackTap,
      content: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: Insets.large,
              ),
              child: Text(
                AppLocalizations.of(context)!.login,
                style: GoogleFonts.bungee().copyWith(
                  fontSize: 52,
                  color: Theme.of(context).primaryColorDark,
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
                  hint: AppLocalizations.of(context)!.username,
                  controller: state.usernameFieldController,
                  validator: state.validateUsernameField,
                  errorState: state.usernameFieldError,
                  additionalError: state.loginUsernameExceptionError,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: Insets.small),
                child: OnboardingField(
                  hint: AppLocalizations.of(context)!.password,
                  obscureText: true,
                  controller: state.passwordFieldController,
                  validator: state.validatePasswordField,
                  errorState: state.passwordFieldError,
                  additionalError: state.loginPasswordExceptionError,
                ),
              ),
              DarkOnboardingButton(
                onPressed: state.handleBasicAuthLoginSubmit,
                text: AppLocalizations.of(context)!.submit,
                width: 350,
                loading: state.loginProcessing,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Insets.large,
            horizontal: Insets.xLarge,
          ),
          child: Divider(
            thickness: 2,
            height: Insets.large,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: Insets.small,
              ),
              child: LightButton(
                onPressed: state.handleGoogleLogin,
                text: AppLocalizations.of(context)!.loginWithGoogle,
                icon: Image.asset(
                  ImageAsset.google.path,
                  height: 24,
                  width: 24,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            if (Device.isIOS || Device.isMacOS)
              LightButton(
                onPressed: state.handleAppleLogin,
                text: AppLocalizations.of(context)!.loginWithApple,
                icon: Image.asset(
                  ImageAsset.apple.path,
                  height: 24,
                  width: 24,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
