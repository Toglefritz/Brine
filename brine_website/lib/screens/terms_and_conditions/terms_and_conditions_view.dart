import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../values/insets.dart';
import 'terms_and_conditions_controller.dart';

/// View for the [HomeRoute].
///
/// Presents a series of [Card]s that showcase software developed by Splendid Endeavors.
class TermsAndConditionsView extends StatelessWidget {
  final TermsAndConditionsController state;

  const TermsAndConditionsView(this.state, {Key? key}) : super(key: key);

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
                style: GoogleFonts.mavenPro().copyWith(
                  fontSize: 16.0,
                  color: Theme.of(context).primaryColorDark,
                ),
                children: const <TextSpan>[
                  TextSpan(
                    text: 'Terms and Conditions\n\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: '1. Use of Brine and App\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        '1.1 Brine is an IoT device designed to monitor the level of salt remaining in your water softener. It operates by measuring the salt level approximately every 24 hours and communicates the data to the App via cloud services.\n1.2 The App provides you with real-time access to the salt level in your water softener and sends notifications when the salt level is low. It also reports the estimated remaining battery life of the Brine device.\n1.3 You must install Brine in your water softener as instructed in the user manual provided with the device.\n1.4 During the initial setup process, the App uses Bluetooth communication between Brine and your mobile device to facilitate the configuration.',
                  ),
                  TextSpan(
                    text: '\n\n2. Account Registration\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        '2.1 To use Brine and the App, you must create a user account on the Brine website or through the App.\n2.2 You are responsible for maintaining the confidentiality of your account credentials, including your username and password.\n2.3 You agree to provide accurate and up-to-date information during the registration process and to update any changes promptly.',
                  ),
                  TextSpan(
                    text: '\n\n3. Privacy\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        '3.1 The collection, use, storage, and disclosure of personal information provided by you are subject to our Privacy Policy, which can be found on the Brine website.\n3.2 By using Brine, the App, or the Services, you consent to the collection, use, storage, and disclosure of your personal information as outlined in the Privacy Policy.',
                  ),
                  TextSpan(
                    text: '\n\n4. Intellectual Property\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        '4.1 Brine, the App, and all associated intellectual property rights are owned by the Brine company or its licensors.\n4.2 You are granted a limited, non-exclusive, non-transferable license to use Brine and the App solely for personal, non-commercial purposes.\n4.3 You agree not to reproduce, modify, distribute, sell, lease, or exploit any part of Brine, the App, or the Services without prior written permission from the Brine company.',
                  ),
                  TextSpan(
                    text: '\n\n5. Limitations and Disclaimers\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '5.1 Brine provides salt level measurements and estimated battery life as a convenience. The accuracy and reliability of these measurements may vary and are not guaranteed.\n5.2 Brine operates on a periodic measurement schedule of approximately 24 hours and does not provide real-time monitoring.\n5.3 The Brine company does not assume any liability for damages or losses resulting from the use or misuse of Brine, the App, or the Services.\n5.4 You acknowledge that the Brine company does not control the availability, quality, or reliability of your home WiFi network, and any interruption or failure in the network may affect the functionality of Brine or the App.',
                  ),
                  TextSpan(
                    text: '\n\n6. Purchasing and Warranty\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        '6.1 Brine devices can be purchased through the Brine website or other authorized channels. Prices, payment methods, and shipping terms are specified during the purchase process.\n6.2 Brine devices are covered by a limited warranty against defects in materials and workmanship for a period of one year from the date of purchase.\n6.3 The warranty does not cover damage caused by improper installation, negligence, accidents, modifications, or unauthorized repairs.\n6.4 To request warranty service, please contact customer support as provided on the Brine website or in the App.',
                  ),
                  TextSpan(
                    text: '\n\n7. Modifications and Termination\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        '7.1 The Brine company reserves the right to modify, suspend, or terminate Brine, the App, or the Services at any time, with or without prior notice.\n7.2 The Brine company may release updates, upgrades, or new versions of the App or Brine devices from time to time, which may require you to update your devices or software to continue using the Services.\n7.3 You may terminate your use of Brine, the App, or the Services at any time by discontinuing their use and uninstalling the App from your mobile device.\n7.4 The Brine company reserves the right to terminate your access to Brine, the App, or the Services if you violate these Terms or engage in any unauthorized or prohibited activities.',
                  ),
                  TextSpan(
                    text: '\n\n8. Indemnification\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        '8.1 You agree to indemnify and hold harmless the Brine company, its affiliates, officers, directors, employees, and agents from any claims, damages, liabilities, costs, or expenses (including reasonable attorneys\' fees) arising out of or related to your use of Brine, the App, or the Services, your violation of these Terms, or your infringement of any rights of a third party.',
                  ),
                  TextSpan(
                    text: '\n\n9. Governing Law and Jurisdiction\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        '9.1 These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which the Brine company is located.\n9.2 Any dispute arising out of or relating to these Terms, Brine, the App, or the Services shall be subject to the exclusive jurisdiction of the courts in the jurisdiction in which the Brine company is located.',
                  ),
                  TextSpan(
                    text: '\n\n10. Severability\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        '10.1 If any provision of these Terms is found to be unlawful, void, or unenforceable, that provision shall be deemed severable and shall not affect the validity and enforceability of the remaining provisions.',
                  ),
                  TextSpan(
                    text: '\n\n11. Entire Agreement\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        '11.1 These Terms constitute the entire agreement between you and the Brine company regarding the use of Brine, the App, and the Services, and supersede any prior agreements or understandings, whether written or oral.',
                  ),
                  TextSpan(
                    text:
                        '\n\nBy using Brine, the App, or the Services, you acknowledge that you have read, understood, and agreed to these Terms and Conditions. If you do not agree with any part of these Terms, please refrain from using Brine, the App, or the Services.',
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
