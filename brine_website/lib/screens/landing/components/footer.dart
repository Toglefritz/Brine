import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../values/insets.dart';
import 'footer_button.dart';

/// THe [Footer] appears at the bottom of the [HomeView] and contains a set of navigational
/// buttons to administrative pages on the site.
class Footer extends StatelessWidget {
  const Footer({
    super.key,
  });

  /// Handles taps on the terms and conditions button.
  void termsAndConditionsOnTap(BuildContext context) {
    //context.go(const TermsAndConditionsRoute().screenName);
  }

  /// Handles taps on the privacy policy button.
  void privacyPolicyOnTap(BuildContext context) {
    //context.go(const PrivacyPolicyRoute().screenName);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: insetsMedium),
          child: Text(
            AppLocalizations.of(context).legalStuff,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(insetsSmall),
          child: FooterButton(
            text: AppLocalizations.of(context).termsAndConditions,
            onPressed: () => termsAndConditionsOnTap(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: insetsSmall, right: insetsMedium),
          child: FooterButton(
            text: AppLocalizations.of(context).privacyPolicy,
            onPressed: () => privacyPolicyOnTap(context),
          ),
        ),
      ],
    );
  }
}
