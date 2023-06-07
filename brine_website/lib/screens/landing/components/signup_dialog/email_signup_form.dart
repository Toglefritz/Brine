import 'package:brinemonitor/screens/landing/components/icon_animated_button_vertical.dart';
import 'package:brinemonitor/services/firestore/add_lead_function.dart';
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
  /// If the input to the form is valid, this method calls the [callAddLeadFunction] Firebase callable function to submit
  /// the lead to Firebase, which creates a new record in Firestore for the new lead.
  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      // Submit the lead to Firebase
      callAddLeadFunction(
        name: _nameFieldController.text,
        email: _emailFieldController.text,
      );
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
            padding: const EdgeInsets.only(
              left: insetsLarge,
            ),
            child: Text(
              AppLocalizations.of(context).nameFieldHint,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: insetsLarge),
            child: TextFormField(
              controller: _nameFieldController,
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
                color: Theme.of(context).primaryColorDark,
              ),
              validator: (entry) => validateNameField(
                context: context,
                entry: entry,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: insetsLarge,
              left: insetsLarge,
            ),
            child: Text(
              AppLocalizations.of(context).emailFieldHint,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: insetsLarge),
            child: TextFormField(
              controller: _emailFieldController,
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
                color: Theme.of(context).primaryColorDark,
              ),
              validator: (entry) => validateEmailField(
                context: context,
                entry: entry,
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
