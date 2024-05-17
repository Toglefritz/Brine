import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/light_button.dart';
import '../../../extensions/brightness_extensions.dart';
import '../../../models/device.dart';
import '../../../theme/insets.dart';
import '../components/authentication_page.dart';
import '../components/dark_onboarding_button.dart';
import '../components/onboarding_field.dart';
import 'components/borderless_field.dart';
import 'create_account_controller.dart';
import 'create_account_route.dart';

/// View for [CreateAccountRoute].
class CreateAccountView extends StatelessWidget {
  /// Creates an instance of [CreateAccountView].
  const CreateAccountView(this.state, {super.key});

  /// A controller for this view.
  final CreateAccountController state;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(Theme.of(context).brightness.oppositeSystemOverlayStyle());

    return AuthenticationPage(
      backOnTap: state.handleBackTap,
      content: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: Insets.large,
              ),
              child: Text(
                AppLocalizations.of(context)!.createAccount,
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
          key: state.createAccountFormKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: Insets.small),
                child: OnboardingField(
                  hint: AppLocalizations.of(context)!.username,
                  controller: state.usernameFieldController,
                  keyboardType: TextInputType.emailAddress,
                  validator: state.validateUsernameField,
                  errorState: state.usernameFieldError,
                  additionalError: state.createAccountUsernameExceptionError,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: Insets.small),
                child: SizedBox(
                  width: 350,
                  child: Stack(
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            width: 3,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 51),
                        child: Divider(
                          thickness: 3,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      BorderlessField(
                        hint: AppLocalizations.of(context)!.password,
                        obscureText: true,
                        controller: state.passwordFieldController,
                        validator: state.validatePasswordField,
                        errorState: state.passwordFieldError,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 57),
                        child: BorderlessField(
                          hint: AppLocalizations.of(context)!.confirmPassword,
                          obscureText: true,
                          controller: state.passwordConfirmationFieldController,
                          validator: state.validatePasswordConfirmationField,
                          errorState: state.passwordConfirmationFieldError,
                          additionalError: state.createAccountPasswordExceptionError,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DarkOnboardingButton(
                onPressed: state.handleCreateAccountSubmit,
                text: AppLocalizations.of(context)!.submit,
                width: 350,
                loading: state.creatingAccount,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Insets.medium,
            horizontal: Insets.xLarge,
          ),
          child: Divider(
            thickness: 2,
            height: Insets.large,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: Insets.small,
              ),
              child: LightButton(
                onPressed: state.handleGoogleCreateAccount,
                text: AppLocalizations.of(context)!.signUpWithGoogle,
                icon: FontAwesomeIcons.google,
              ),
            ),
            if (Device.isIOS || Device.isMacOS)
              LightButton(
                onPressed: state.handleAppleCreateAccount,
                text: AppLocalizations.of(context)!.signUpWithApple,
                icon: FontAwesomeIcons.apple,
              ),
          ],
        ),
      ],
    );
  }
}
