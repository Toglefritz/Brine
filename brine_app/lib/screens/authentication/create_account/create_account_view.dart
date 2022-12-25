import 'package:brine/models/device.dart';
import 'package:brine/models/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../values/strings.dart';
import '../components/dark_onboarding_button.dart';
import '../components/onboarding_button.dart';
import '../components/onboarding_field.dart';
import '../onboarding/components/onboarding_legal_prompt.dart';
import 'components/borderless_field.dart';
import 'create_account_controller.dart';

/// View for [CreateAccountRoute].
class CreateAccountView extends StatelessWidget {
  final CreateAccountController state;

  const CreateAccountView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          resizeToAvoidBottomInset: false,
          body: Center(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
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
                              Strings.createAccount,
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
                        key: state.createAccountFormKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: Insets.small),
                              child: OnboardingField(
                                hint: Strings.username,
                                controller: state.usernameFieldController,
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
                                          width: 3.0,
                                          color: ColorLibrary.primaryDefault,
                                        ),
                                        color: ColorLibrary.primaryLight,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 51),
                                      child: Divider(
                                        thickness: 3,
                                        color: ColorLibrary.primaryDefault,
                                      ),
                                    ),
                                    BorderlessField(
                                      hint: Strings.password,
                                      obscureText: true,
                                      controller: state.passwordFieldController,
                                      validator: state.validatePasswordField,
                                      errorState: state.passwordFieldError,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 57),
                                      child: BorderlessField(
                                        hint: Strings.confirmPassword,
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
                              text: Strings.submit,
                              width: 350,
                              loading: state.creatingAccount,
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Insets.medium,
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
                              onPressed: state.handleGoogleCreateAccount,
                              text: Strings.signUpWithGoogle,
                              icon: FontAwesomeIcons.google,
                            ),
                          ),
                          if (Device.isIOS)
                            OnboardingButton(
                              onPressed: state.handleAppleCreateAccount,
                              text: Strings.signUpWithApple,
                              icon: FontAwesomeIcons.apple,
                            ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(
                                Insets.medium,
                              ),
                              child: OnboardingLegalPrompt(),
                            ),
                          ],
                        ),
                      ),
                    ],
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
