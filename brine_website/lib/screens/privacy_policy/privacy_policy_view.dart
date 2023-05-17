import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../values/insets.dart';
import 'privacy_policy_controller.dart';

/// View for the [PrivacyPolicyRoute].
///
/// Presents a series of [Card]s that showcase software developed by Splendid Endeavors.
class PrivacyPolicyView extends StatelessWidget {
  final PrivacyPolicyController state;

  const PrivacyPolicyView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryColorDark,
          ),
          onPressed: state.onBackPressed,
        ),
        backgroundColor: Theme.of(context).primaryColorLight,
        title: Text(
          AppLocalizations.of(context).brine,
          style: GoogleFonts.mavenPro().copyWith(
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).primaryColorDark,
                width: 2.0,
              ),
              top: BorderSide(
                color: Theme.of(context).primaryColorDark,
                width: 3.0,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              insetsLarge,
            ),
            child: SelectableText.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 16.0,
                      color: Theme.of(context).primaryColorDark,
                    ),
                children: const <TextSpan>[
                  TextSpan(
                    text: 'Privacy Policy\n\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text:
                        'At Brine, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our Brine IoT device, companion mobile application ("App"), and associated services ("Services"). By using Brine, the App, or the Services, you consent to the terms of this Privacy Policy.\n\n',
                  ),
                  TextSpan(
                    text: 'Information We Collect\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        'We may collect personal information that you provide to us when you create a user account, such as your name, email address, and contact information. We also collect device-specific information, including unique device identifiers and network information, to enable communication between Brine and the App. Additionally, we may collect usage data and analytics information to improve our Services.\n\n',
                  ),
                  TextSpan(
                    text: 'How We Use Your Information\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        'We use the information we collect to provide, maintain, and improve Brine, the App, and the Services. This includes delivering notifications about low salt levels, estimating battery life, and enhancing user experience. We may also use your information to communicate important updates, promotions, or offers related to Brine.\n\n',
                  ),
                  TextSpan(
                    text: 'Information Sharing and Disclosure\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        'We do not sell, trade, or rent your personal information to third parties. However, we may share your information with trusted service providers who assist us in delivering our Services, such as cloud hosting providers and analytics platforms. We may also disclose your information to comply with legal obligations or protect our rights, safety, or property.\n\n',
                  ),
                  TextSpan(
                    text: 'Data Security\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        'We implement reasonable security measures to protect your information from unauthorized access, alteration, disclosure, or destruction. However, please be aware that no method of transmission over the internet or electronic storage is completely secure, and we cannot guarantee absolute security.\n\n',
                  ),
                  TextSpan(
                    text: 'Children\'s Privacy\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Brine is not intended for use by individuals under the age of 13. We do not knowingly collect personal information from children. If you believe that we may have collected information from a child, please contact us to request deletion.\n\n',
                  ),
                  TextSpan(
                    text: 'Changes to this Privacy Policy\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        'We reserve the right to update or modify this Privacy Policy at any time. Any changes will be effective immediately upon posting the updated Privacy Policy. We encourage you to review this Privacy Policy periodically for any updates.\n\n',
                  ),
                  TextSpan(
                    text: 'Contact Us\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        'If you have any questions, concerns, or suggestions regarding this Privacy Policy or our privacy practices, please contact us at hello@splendidendeavors.com.\n\n',
                  ),
                  TextSpan(
                    text: 'Last Updated\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'This Privacy Policy was last updated on May 16, 2023.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
