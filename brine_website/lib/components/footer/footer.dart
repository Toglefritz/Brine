import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../screens/privacy_policy/privacy_policy_route.dart';
import '../../screens/terms_and_conditions/terms_and_conditions_route.dart';
import '../../values/insets.dart';
import 'footer_button.dart';

/// THe [Footer] appears at the bottom of the home screen and contains a set of navigational buttons to administrative
/// pages on the site.
class Footer extends StatelessWidget {
  /// Creates a [Footer] widget.
  const Footer({
    super.key,
  });

  /// Handles taps on the terms and conditions button.
  Future<void> _termsAndConditionsOnTap(BuildContext context) async {
    await context.push(TermsAndConditionsRoute.screenName);
  }

  /// Handles taps on the privacy policy button.
  Future<void> _privacyPolicyOnTap(BuildContext context) async {
    await context.push(PrivacyPolicyRoute.screenName);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            right: Insets.medium,
          ),
          child: Text(
            AppLocalizations.of(context)!.legalStuff,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(Insets.small),
          child: FooterButton(
            text: AppLocalizations.of(context)!.termsAndConditions,
            onPressed: () => _termsAndConditionsOnTap(context),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: Insets.small,
            right: Insets.medium,
          ),
          child: FooterButton(
            text: AppLocalizations.of(context)!.privacyPolicy,
            onPressed: () => _privacyPolicyOnTap(context),
          ),
        ),
      ],
    );
  }
}
