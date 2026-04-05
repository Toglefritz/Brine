import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/analytics/analytics.dart';
import '../../../../services/authentication/sign_in_anonymously.dart';
import '../../../../services/lead_management/add_lead_function.dart';
import '../../../../values/insets.dart';
import '../../../thanks/thanks_route.dart';
import '../icon_animated_button_vertical.dart';

/// A [Form] used to collect a name and email from the visitor so they can be notified about updates for Brine.
class EmailSignupForm extends StatefulWidget {
  /// Creates an instance of [EmailSignupForm].
  const EmailSignupForm({
    super.key,
  });

  @override
  State<EmailSignupForm> createState() => _EmailSignupFormState();
}

/// State class for [EmailSignupForm].
class _EmailSignupFormState extends State<EmailSignupForm> {
  /// A key for the email option form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// A controller for the name entry [TextFormField].
  final TextEditingController _nameFieldController = TextEditingController();

  /// A controller for the email entry [TextFormField].
  final TextEditingController _emailFieldController = TextEditingController();

  /// Determines if a valid submission to the form is currently being processed.
  bool processingLead = false;

  /// Validates the user's first name entry for a form.
  ///
  /// The function takes two parameters, [context] and [entry]. The [context] parameter is required for localization
  /// purposes, and the [entry] parameter is the user's first name input.
  ///
  /// The following validation checks are performed on the input:
  /// 1. Checks if the input is null or empty, if so, returns a localized message indicating that
  /// the name field cannot be empty.
  ///
  /// 2. Checks if the length of the input is greater than 50 characters, if so, returns a localized
  /// message indicating that the name is too long.
  ///
  /// 3. Checks if the input only contains alphabets, hyphens, apostrophes, or spaces. If other
  /// characters are found, returns a localized message indicating that the name contains invalid characters.
  ///
  /// 4. Checks if the input contains any HTML tags or JavaScript code to prevent XSS attacks. If such
  /// characters are found, returns a localized message indicating that HTML tags are not allowed.
  ///
  /// 5. Checks if the input contains control characters which are non-printable characters that could
  /// be used maliciously. If found, returns a localized message indicating that control characters are not allowed.
  ///
  /// 6. Normalizes the input to a standard Unicode form (Normalization Form C) to ensure consistency
  /// and prevent issues with different Unicode representations.
  ///
  /// The function returns `null` if all validation checks pass, indicating that the input is valid. If any of the
  /// validation checks fail, the function returns a localized error message string.
  ///
  /// Returns `null` if the input passes all validation checks, otherwise returns a localized error message.
  String? _validateNameField({
    required BuildContext context,
    required String? entry,
  }) {
    if (entry == null || entry.isEmpty) {
      unawaited(
        Analytics.logEvent(
          name: 'name_field_error',
          parameters: {
            'error': 'empty or null',
          },
        ),
      );

      return AppLocalizations.of(context)!.validationNameEmpty;
    }

    // 1. Length check - truncate if length is greater than 30
    if (entry.length > 30) {
      unawaited(
        Analytics.logEvent(
          name: 'name_field_error',
          parameters: {
            'error': 'name too long',
          },
        ),
      );

      _nameFieldController.text = _nameFieldController.text
          .replaceRange(30, _nameFieldController.text.length, '...');
    }

    // Update the local variable after length truncation
    final String sanitizedEntry = _nameFieldController.text;

    // 2. Character set limitation - remove characters not in [a-zA-Z-', ]
    String validCharacters = '';
    for (int i = 0; i < sanitizedEntry.length; i++) {
      if (RegExp(r"^[a-zA-Z\-'\s]$").hasMatch(sanitizedEntry[i])) {
        validCharacters += sanitizedEntry[i];
      }
    }
    _nameFieldController.text = validCharacters;

    // 3. Escape or Strip HTML (Enhanced checks)
    final RegExp htmlCharacters = RegExp(
      r'<|>|&|"|\|/|<!--|-->|!DOCTYPE|=|javascript:|data:|@import|expression\(|`|;',
    );
    if (htmlCharacters.hasMatch(sanitizedEntry)) {
      unawaited(
        Analytics.logEvent(
          name: 'name_field_error',
          parameters: {
            'error': 'contains HTML',
          },
        ),
      );

      return AppLocalizations.of(context)!.validationNameInvalidHtml;
    }

    // 4. Reject Control Characters
    final RegExp controlCharacters = RegExp(r'[\x00-\x1F\x7F-\x9F]');
    if (controlCharacters.hasMatch(sanitizedEntry)) {
      unawaited(
        Analytics.logEvent(
          name: 'name_field_error',
          parameters: {
            'error': 'contains control characters',
          },
        ),
      );

      return AppLocalizations.of(context)!.validationNameControlCharacters;
    }

    return null;
  }

  /// Validates the user's email address entry for a form.
  ///
  /// The function takes two parameters, [context] and [entry]. The [context] parameter is required for localization
  /// purposes, and the [entry] parameter is the user's email address input.
  ///
  /// The following validation checks are performed on the input:
  /// 1. Checks if the input is null or empty, if so, returns a localized message indicating that
  /// the email field cannot be empty.
  ///
  /// 2. Checks if the input is in a valid email format, if not, returns a localized message
  /// indicating that the email address is invalid.
  ///
  /// 3. Checks if the input contains any HTML tags or JavaScript code to prevent XSS attacks. If such
  /// characters are found, returns a localized message indicating that HTML tags are not allowed.
  ///
  /// 4. Checks if the input contains control characters which are non-printable characters that could
  /// be used maliciously. If found, returns a localized message indicating that control characters are not allowed.
  ///
  /// 5. Normalizes the input to a standard Unicode form (Normalization Form C) to ensure consistency
  /// and prevent issues with different Unicode representations.
  ///
  /// The function returns `null` if all validation checks pass, indicating that the input is valid. If any of the
  /// validation checks fail, the function returns a localized error message string.
  ///
  /// Returns `null` if the input passes all validation checks, otherwise returns a localized error message.
  String? _validateEmailField({
    required BuildContext context,
    required String? entry,
  }) {
    // Regular expression pattern for validating email address
    const String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final RegExp regex = RegExp(pattern);

    // Check if the entry is null or empty
    if (entry == null || entry.isEmpty) {
      unawaited(
        Analytics.logEvent(
          name: 'email_field_error',
          parameters: {
            'error': 'empty or null',
          },
        ),
      );

      return AppLocalizations.of(context)!.validationEmailEmpty;
    }

    // Check if the email address is in valid format
    if (!regex.hasMatch(entry)) {
      unawaited(
        Analytics.logEvent(
          name: 'email_field_error',
          parameters: {
            'error': 'invalid email format',
          },
        ),
      );

      return AppLocalizations.of(context)!.validationEmailInvalid;
    }

    // Check for HTML characters/tags
    final RegExp htmlCharacters = RegExp(
      r'<|>|&|"|\|/|<!--|-->|!DOCTYPE|=|javascript:|data:|@import|expression\(|`|;',
    );
    if (htmlCharacters.hasMatch(entry)) {
      unawaited(
        Analytics.logEvent(
          name: 'email_field_error',
          parameters: {
            'error': 'contains HTML',
          },
        ),
      );

      return AppLocalizations.of(context)!.validationEmailHtmlCharacters;
    }

    // Reject Control Characters
    final RegExp controlCharacters = RegExp(r'[\x00-\x1F\x7F-\x9F]');
    if (controlCharacters.hasMatch(entry)) {
      unawaited(
        Analytics.logEvent(
          name: 'email_field_error',
          parameters: {
            'error': 'contains control characters',
          },
        ),
      );

      return AppLocalizations.of(context)!.validationEmailControlCharacters;
    }

    return null;
  }

  /// Handles submissions of the signup form.
  ///
  /// If the input to the form is valid, this method calls the [LeadsService] Firebase callable function to submit the
  /// lead to Firebase, which creates a new record in Firestore for the new lead. Assuming this cloud function call is
  /// successful, the method will return a `true` value via a call to [Navigator.pop].
  ///
  /// Because it takes time for the Firebase backend to process the new lead, a loading indicator is displayed in place
  /// of the form's submit button while the app waits for a response from the endpoint. This method sets
  /// [processingLead] to true while waiting for this response.
  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      // Sign in anonymously
      try {
        await signInAnonymously();
      }
      // ignore: avoid_catches_without_on_clauses
      catch (error, stackTrace) {
        debugPrint('Authentication failed for addLead function');

        if (!kDebugMode) {
          await FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            reason: 'authentication failed',
          );
        }

        // TODO(Toglefritz): how should this error be handled?

        return;
      }

      if (_formKey.currentState!.validate()) {
        // Turn on the loading indicator
        setState(() {
          processingLead = true;
        });

        try {
          // Submit the lead to Firebase
          await LeadsService().submitLead(
            name: _nameFieldController.text,
            email: _emailFieldController.text,
          );
        }
        // ignore: avoid_catches_without_on_clauses
        catch (error, stackTrace) {
          debugPrint('Failed to add lead to Firebase');

          setState(() {
            processingLead = false;
          });

          if (!kDebugMode) {
            await FirebaseCrashlytics.instance.recordError(
              error,
              stackTrace,
              reason: 'failed to create lead',
            );
          }

          // TODO(Toglefritz): how should this error be handled?

          return;
        }

        // Update the anonymous profile
        await FirebaseAuth.instance.currentUser
            ?.updateDisplayName(_nameFieldController.text);

        if (!kDebugMode) {
          await FirebaseAnalytics.instance.logGenerateLead();
        }

        // Return true to the caller to indicate success
        if (!mounted) return;
        context.pushReplacement(
          '${ThanksRoute.screenName}/${_nameFieldController.text}',
        );
      }
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
              top: Insets.large,
              right: Insets.large,
              left: Insets.large,
            ),
            child: TextFormField(
              controller: _nameFieldController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: Insets.medium,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Insets.medium,
                  ),
                  child: const Icon(Icons.person),
                ),
                labelText: AppLocalizations.of(context)!.nameFieldHint,
              ),
              style: GoogleFonts.shareTechMono().copyWith(
                color: Theme.of(context).primaryColorDark,
              ),
              validator: (entry) => _validateNameField(
                context: context,
                entry: entry,
              ),
              onFieldSubmitted: (entry) => _onSubmit(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Insets.large,
              right: Insets.large,
              left: Insets.large,
            ),
            child: TextFormField(
              controller: _emailFieldController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: Insets.medium,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Insets.medium,
                  ),
                  child: const Icon(Icons.mail),
                ),
                labelText: AppLocalizations.of(context)!.emailFieldHint,
              ),
              style: GoogleFonts.shareTechMono().copyWith(
                color: Theme.of(context).primaryColorDark,
              ),
              validator: (entry) => _validateEmailField(
                context: context,
                entry: entry,
              ),
              onFieldSubmitted: (entry) => _onSubmit(),
            ),
          ),
          if (!processingLead)
            Padding(
              padding: EdgeInsets.only(
                top: Insets.xLarge,
                bottom: Insets.large,
              ),
              child: IconAnimatedButtonVertical(
                buttonText: AppLocalizations.of(context)!.emailOptinButtonText,
                onTap: _onSubmit,
              ),
            ),
          if (processingLead)
            Padding(
              padding: EdgeInsets.only(
                top: Insets.xLarge,
                bottom: Insets.large,
              ),
              child: SpinKitWave(
                color: Theme.of(context).primaryColorDark,
                size: 36,
              ),
            ),
        ],
      ),
    );
  }
}
