import 'package:brinemonitor/screens/landing/components/icon_animated_button_vertical.dart';
import 'package:brinemonitor/screens/thanks/thanks_route.dart';
import 'package:brinemonitor/values/insets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../services/authentication/sign_in_anonymously.dart';
import '../../../../services/lead_management/add_lead_function.dart';

/// A [Form] used to collect a name and email from the visitor so they can be notified about updates for Brine.
class EmailSignupForm extends StatefulWidget {
  const EmailSignupForm({
    super.key,
  });

  @override
  State<EmailSignupForm> createState() => _EmailSignupFormState();
}

class _EmailSignupFormState extends State<EmailSignupForm> {
  /// A key for the email optin form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// A controller for the name entry [TextFormField].
  final TextEditingController _nameFieldController = TextEditingController();

  /// A controller for the email entry [TextFormField].
  final TextEditingController _emailFieldController = TextEditingController();

  /// Validates inputs into the name field.
  String? validateNameField({required BuildContext context, required String? entry}) {
    if (entry == null || entry.isEmpty) {
      return AppLocalizations.of(context).validationNameEmpty;
    } else {
      return null;
    }
  }

  /// Validates an email address.
  ///
  /// This function uses a regular expression to validate the format of the email address. If the email is null,
  /// empty or not in the correct format, the function will return a corresponding error message.
  String? validateEmailField({required BuildContext context, required String? entry}) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (entry == null || entry.isEmpty) {
      return AppLocalizations.of(context).validationEmailEmpty;
    } else if (!regex.hasMatch(entry)) {
      return AppLocalizations.of(context).validationEmailInvalid;
    } else {
      return null;
    }
  }

  /// Handles submissions of the signup form.
  ///
  /// If the input to the form is valid, this method calls the [callAddLeadFunction] Firebase callable function to
  /// submit the lead to Firebase, which creates a new record in Firestore for the new lead. Assuming this cloud
  /// function call is successful, the method will return a `true` value via a call to [Navigator.pop].
  Future<void> _onSubmit() async {
    // Sign in anonymously
    try {
      await signInAnonymously();
    } catch (e) {
      debugPrint('Authentication failed for addLead function');

      // TODO how should this error be handled?

      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        // Submit the lead to Firebase
        await callAddLeadFunction(
          name: _nameFieldController.text,
          email: _emailFieldController.text,
        );
      } catch (e) {
        debugPrint('Failed to add lead to Firebase');

        // TODO how should this error be handled?

        return;
      }

      // Return true to the caller to indicate success
      if (!mounted) return;
      context.pushReplacement('${ThanksRoute.screenName}/${_nameFieldController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: Insets.kInsetsLarge,
              right: Insets.kInsetsLarge,
              left: Insets.kInsetsLarge,
            ),
            child: TextFormField(
              controller: _nameFieldController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: Insets.kInsetsMedium,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Insets.kInsetsMedium,
                  ),
                  child: const Icon(Icons.person),
                ),
                labelText: AppLocalizations.of(context).nameFieldHint,
              ),
              style: GoogleFonts.shareTechMono().copyWith(
                color: Theme.of(context).primaryColorDark,
              ),
              validator: (entry) => validateNameField(
                context: context,
                entry: entry,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Insets.kInsetsLarge,
              right: Insets.kInsetsLarge,
              left: Insets.kInsetsLarge,
            ),
            child: TextFormField(
              controller: _emailFieldController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: Insets.kInsetsMedium,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Insets.kInsetsMedium,
                  ),
                  child: const Icon(Icons.mail),
                ),
                labelText: AppLocalizations.of(context).emailFieldHint,
              ),
              style: GoogleFonts.shareTechMono().copyWith(
                color: Theme.of(context).primaryColorDark,
              ),
              validator: (entry) => validateEmailField(
                context: context,
                entry: entry,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Insets.kInsetsXLarge,
              bottom: Insets.kInsetsLarge,
            ),
            child: IconAnimatedButtonVertical(
              buttonText: AppLocalizations.of(context).emailOptinButtonText,
              onTap: () => _onSubmit(),
            ),
          ),
        ],
      ),
    );
  }
}
