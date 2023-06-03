import 'package:brinemonitor/screens/landing/components/signup_dialog/email_signup_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../values/insets.dart';
import 'animated_dialog.dart';

/// Presents an [AnimatedDialog] with a form allowing the user to sign up for notifications about Brine.
class EmailOptinAnimatedDialog extends StatelessWidget {
  const EmailOptinAnimatedDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedDialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(insetsMedium),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context).landingPageEmailInvite,
                  style: GoogleFonts.changaOne().copyWith(
                    fontSize: 42,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(insetsLarge),
                  child: Text(
                    AppLocalizations.of(context).emailOptinDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                EmailSignupForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
