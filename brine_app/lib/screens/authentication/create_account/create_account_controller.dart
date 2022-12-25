import 'package:brine/screens/authentication/onboarding/onboarding_route.dart';
import 'package:flutter/material.dart';

import '../../../values/regex.dart';
import 'create_account_route.dart';
import 'create_account_view.dart';

/// Controller for [CreateAccountRoute].
class CreateAccountController extends State<CreateAccountRoute> {
  /// A key used for the username and password login form.
  final createAccountFormKey = GlobalKey<FormState>();

  /// A controller used for the username field.
  final usernameFieldController = TextEditingController();

  /// A controller used for the password field.
  final passwordFieldController = TextEditingController();

  /// A controller used for the password confirmation field.
  final passwordConfirmationFieldController = TextEditingController();

  /// Determines if the username field is in an error state, which is, in turn, determined by the
  /// [validateUsernameField] method.
  bool usernameFieldError = false;

  /// Determines if the password field is in an error state, which is, in turn, determined by the
  /// [validatePasswordField] method.
  bool passwordFieldError = false;

  /// Determines if the password confirmation field is in an error state, which is, in turn, determined by the
  /// [validatePasswordConfirmationField] method.
  bool passwordConfirmationFieldError = false;

  /// Handles submission of the username and password to perform basic authentication against Firebase.
  void handleCreateAccountSubmit() {
    if (createAccountFormKey.currentState!.validate()) {
      // TODO form validation
    }
  }

  /// Validates the username field.
  String? validateUsernameField(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        usernameFieldError = true;
      });

      return 'Oops. Enter a username, please.';
    } else if (!RegEx.emailAddress.hasMatch(value)) {
      setState(() {
        usernameFieldError = true;
      });

      return 'This doesn\'t seem to be a valid email address.';
    }

    setState(() {
      usernameFieldError = false;
    });

    return null;
  }

  /// Validates the password field.
  // This method always returns null because the [validatePasswordConfirmationField] method handles validation
  // for both password field.
  String? validatePasswordField(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        passwordFieldError = true;
      });
    } else if (value.length < 6) {
      setState(() {
        passwordFieldError = true;
      });
    }

    setState(() {
      passwordFieldError = false;
    });

    return null;
  }

  /// Validates the password field.
  String? validatePasswordConfirmationField(String? value) {
    if (passwordFieldController.text.isEmpty) {
      return 'Ummm... you\'ll need to enter a password.';
    } else if (passwordFieldController.text.length < 6) {
      return 'A minimum of six characters, please.';
    } else if (value == null || value.isEmpty) {
      setState(() {
        passwordConfirmationFieldError = true;
      });

      return 'Enter the password again here.';
    } else if (value != passwordFieldController.text) {
      setState(() {
        passwordConfirmationFieldError = true;
      });

      return 'The passwords don\'t match. Hate it when that happens...';
    }

    setState(() {
      passwordConfirmationFieldError = false;
    });

    return null;
  }

  /// Handles taps on the back button.
  void handleBackTap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const OnboardingRoute(),
      ),
    );
  }

  /// Handles taps on the Google sign in button.
  Future<void> handleGoogleCreateAccount() async {
    // TODO create account with Google
  }

  /// Handles taps on the Apple sign in button.
  Future<void> handleAppleCreateAccount() async {
    // TODO create account with Apple
  }

  @override
  Widget build(BuildContext context) => CreateAccountView(this);
}
