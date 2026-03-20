import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../values/insets.dart';
import '../../../../values/screen.dart';
import 'animated_dialog.dart';
import 'email_signup_form.dart';

/// Presents an [AnimatedDialog] with a form allowing the user to sign up for notifications about Brine.
class EmailOptinAnimatedDialog extends StatelessWidget {
  /// Creates an instance of [EmailOptinAnimatedDialog].
  const EmailOptinAnimatedDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedDialog(
      child: SizedBox(
        width: Screen.width(context) * (Screen.width(context) > 700 ? 0.6 : 0.8),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            Insets.medium,
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.landingPageEmailInvite,
                style: GoogleFonts.changaOne().copyWith(
                  fontSize: 42,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Insets.medium,
                  vertical: Insets.large,
                ),
                child: Text(
                  AppLocalizations.of(context)!.emailOptinDescription,
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
