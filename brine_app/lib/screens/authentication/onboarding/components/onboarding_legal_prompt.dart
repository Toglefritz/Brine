import 'package:brine/theme/color_library.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../values/strings.dart';

/// A sentence built with a [RichText] widget prompting the user to view the terms and conditions and
/// the privacy policy before using the app.
class OnboardingLegalPrompt extends StatelessWidget {
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
        text: Strings.onboardingLegalPrompt1,
        children: <TextSpan>[
          TextSpan(
            text: Strings.termsOfService,
            style: const TextStyle(fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = handleTermsAndConditionsTap,
          ),
          const TextSpan(
            text: Strings.and,
          ),
          TextSpan(
            text: Strings.privacyPolicy,
            style: const TextStyle(fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = handlePrivacyPolicyTap,
          ),
          const TextSpan(
            text: Strings.onboardingLegalPrompt2,
          ),
        ],
      ),
    );
  }
}
