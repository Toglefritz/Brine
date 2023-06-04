import 'package:brinemonitor/screens/landing/components/icon_animated_button_vertical.dart';
import 'package:brinemonitor/values/insets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

/// A [Form] used to collect a name and email from the visitor so they can be notified about updates for Brine.
class EmailSignupForm extends StatelessWidget {
  EmailSignupForm({
    super.key,
  });

  /// A key for the email optin form.
  final _formKey = GlobalKey<FormState>();

  /// Handles submissions of the signup form.
  Future<void> _onSubmit() async {
    // TODO implement this and submit the info or something like that
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: insetsMedium,
            ),
            child: Text(
              AppLocalizations
                  .of(context)
                  .nameFieldHint,
              textAlign: TextAlign.start,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: insetsMedium),
            child: TextFormField(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: insetsMedium,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: insetsMedium),
                  child: Icon(Icons.person),
                ),
              ),
              style: GoogleFonts.shareTechMono().copyWith(
                color: Theme
                    .of(context)
                    .primaryColorDark,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: insetsLarge,
              left: insetsLarge,
            ),
            child: Text(
              AppLocalizations
                  .of(context)
                  .emailFieldHint,
              textAlign: TextAlign.start,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: insetsMedium),
            child: TextFormField(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: insetsMedium,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: insetsMedium),
                  child: Icon(Icons.mail),
                ),
              ),
              style: GoogleFonts.shareTechMono().copyWith(
                color: Theme
                    .of(context)
                    .primaryColorDark,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: insetsXLarge,
              bottom: insetsLarge,
            ),
            child: IconAnimatedButtonVertical(
              onTap: _onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
