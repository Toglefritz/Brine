import 'package:brine/theme/color_library.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A sentence built with a [RichText] widget prompting the user to view the terms and conditions and
/// the privacy policy before using the app.
class OnboardingLegalPrompt extends StatelessWidget {
  /// Creates an [OnboardingLegalPrompt].
  const OnboardingLegalPrompt({
    Key? key,
  }) : super(key: key);

  /// Handles taps on the privacy policy link.
  void handleTermsAndConditionsTap() {
    // TODO open terms and conditions
  }

  /// Handles taps on the privacy policy link.
  void handlePrivacyPolicyTap() {
    // TODO open privacy policy
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          color: ColorLibrary.primaryDefault,
        ),
        text: AppLocalizations.of(context).onboardingLegalPrompt1,
        children: <TextSpan>[
          TextSpan(
            text: AppLocalizations.of(context).termsOfService,
            style: const TextStyle(fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = handleTermsAndConditionsTap,
          ),
          TextSpan(
            text: AppLocalizations.of(context).and,
          ),
          TextSpan(
            text: AppLocalizations.of(context).privacyPolicy,
            style: const TextStyle(fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = handlePrivacyPolicyTap,
          ),
          TextSpan(
            text: AppLocalizations.of(context).onboardingLegalPrompt2,
          ),
        ],
      ),
    );
  }
}
