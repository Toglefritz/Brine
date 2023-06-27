import 'package:brinemonitor/screens/landing/components/signup_dialog/email_signup_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../values/insets.dart';
import '../../../../values/screen.dart';
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
        width: Screen.width(context) * 0.6,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            Insets.kInsetsMedium,
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context).landingPageEmailInvite,
                style: GoogleFonts.changaOne().copyWith(
                  fontSize: 42,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Insets.kInsetsMedium,
                  vertical: Insets.kInsetsLarge,
                ),
                child: Text(
                  AppLocalizations.of(context).emailOptinDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const EmailSignupForm(),
            ],
          ),
        ),
      ),
    );
  }
}
