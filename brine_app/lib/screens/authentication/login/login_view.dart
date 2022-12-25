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
          resizeToAvoidBottomInset: false,
          body: CustomScrollView(
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
                            Strings.login,
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
                              hint: Strings.username,
                              controller: state.usernameFieldController,
                              validator: state.validateUsernameField,
                              errorState: state.usernameFieldError,
                              additionalError: state.loginUsernameExceptionError,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: Insets.small),
                            child: OnboardingField(
                              hint: Strings.password,
                              obscureText: true,
                              controller: state.passwordFieldController,
                              validator: state.validatePasswordField,
                              errorState: state.passwordFieldError,
                              additionalError: state.loginPasswordExceptionError,
                            ),
                          ),
                          DarkOnboardingButton(
                            onPressed: state.handleBasicAuthLoginSubmit,
                            text: Strings.submit,
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
                            text: Strings.loginWithGoogle,
                            icon: FontAwesomeIcons.google,
                          ),
                        ),
                        if (Device.isIOS)
                          OnboardingButton(
                            onPressed: state.handleAppleLogin,
                            text: Strings.loginWithApple,
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
