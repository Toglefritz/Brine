import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../services/authentication/authentication_service.dart';
import '../../../services/authentication/models/auth_methods.dart';
import '../../../values/regex.dart';
import '../../setup/setup_route.dart';
import '../onboarding/onboarding_route.dart';
import 'create_account_route.dart';
import 'create_account_view.dart';

/// Controller for [CreateAccountRoute].
class CreateAccountController extends State<CreateAccountRoute> {
  /// A key used for the username and password login form.
  final GlobalKey<FormState> createAccountFormKey = GlobalKey<FormState>();

  /// A controller used for the username field.
  final TextEditingController usernameFieldController = TextEditingController();

  /// A controller used for the password field.
  final TextEditingController passwordFieldController = TextEditingController();

  /// A controller used for the password confirmation field.
  final TextEditingController passwordConfirmationFieldController = TextEditingController();

  /// Determines if the username field is in an error state, which is, in turn, determined by the
  /// [validateUsernameField] method.
  bool usernameFieldError = false;

  /// Determines if the password field is in an error state, which is, in turn, determined by the
  /// [validatePasswordField] method.
  bool passwordFieldError = false;

  /// Determines if the password confirmation field is in an error state, which is, in turn, determined by the
  /// [validatePasswordConfirmationField] method.
  bool passwordConfirmationFieldError = false;

  /// An additional form validation error string set by exceptions thrown during the account creation process related
  /// to the username entry.
  String? createAccountUsernameExceptionError;

  /// An additional form validation error string set by exceptions thrown during the account creation process related
  /// to the password entry.
  String? createAccountPasswordExceptionError;

  /// Determines if the account creation process is in progress
  bool creatingAccount = false;

  /// Handles submission of the username and password to perform basic authentication against Firebase.
  Future<void> handleCreateAccountSubmit() async {
    setState(() {
      createAccountUsernameExceptionError = null;
      createAccountPasswordExceptionError = null;
      usernameFieldError = false;
      passwordFieldError = false;
      creatingAccount = true;
    });

    if (createAccountFormKey.currentState!.validate()) {
      try {
        await AuthenticationService.createUser(
          method: AuthMethod.basicAuth,
          emailAddress: usernameFieldController.text,
          password: passwordFieldController.text,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          setState(() {
            passwordFieldError = true;
            createAccountPasswordExceptionError = 'The password provided is too weak.';
            creatingAccount = false;
          });

          return;
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            usernameFieldError = true;
            createAccountUsernameExceptionError = 'An account already exists using that email.';
            creatingAccount = false;
          });

          return;
        } else if (e.code == 'network-request-failed') {
          setState(() {
            createAccountUsernameExceptionError = 'A network error occurred. Please try again.';
            createAccountPasswordExceptionError = 'A network error occurred. Please try again.';
            usernameFieldError = true;
            passwordFieldError = true;
            creatingAccount = false;
          });

          return;
        } else {
          setState(() {
            createAccountUsernameExceptionError =
                'An unknown error occurred. Not good. Please try again a bit later as this is probably our fault.';
            createAccountPasswordExceptionError =
                'An unknown error occurred. Not good. Please try again a bit later as this is probably our fault.';
            usernameFieldError = true;
            passwordFieldError = true;
            creatingAccount = false;
          });

          return;
        }
      } catch (e) {
        setState(() {
          createAccountUsernameExceptionError =
              'An unknown error occurred. Not good. Please try again a bit later as this is probably our fault.';
          createAccountPasswordExceptionError =
              'An unknown error occurred. Not good. Please try again a bit later as this is probably our fault.';
          usernameFieldError = true;
          passwordFieldError = true;
          creatingAccount = false;
        });

        return;
      }

      setState(() {
        createAccountUsernameExceptionError = null;
        createAccountPasswordExceptionError = null;
        usernameFieldError = false;
        passwordFieldError = false;
        creatingAccount = false;
      });

      debugPrint('Successfully created account, ${FirebaseAuth.instance.currentUser?.uid}');

      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const SetupRoute(),
          ),
        );
      }
    }
  }

  /// Validates the username field.
  String? validateUsernameField(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        usernameFieldError = true;
        creatingAccount = false;
      });

      return 'Oops. Enter a username, please.';
    } else if (!RegEx.emailAddress.hasMatch(value)) {
      setState(() {
        usernameFieldError = true;
        creatingAccount = false;
      });

      return 'This doesn\'t seem to be a valid email address.';
    }

    setState(() {
      usernameFieldError = false;
      creatingAccount = false;
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
        creatingAccount = false;
      });
    } else if (value.length < 6) {
      setState(() {
        passwordFieldError = true;
        creatingAccount = false;
      });
    }

    setState(() {
      passwordFieldError = false;
      creatingAccount = false;
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
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const OnboardingRoute(),
      ),
    );
  }

  /// Handles taps on the Google sign in button.
  Future<void> handleGoogleCreateAccount() async {
    // TODO(Toglefritz): tag

    await AuthenticationService.createUser(method: AuthMethod.google);
  }

  /// Handles taps on the Apple sign in button.
  Future<void> handleAppleCreateAccount() async {
    // TODO(Toglefritz): tag

    await AuthenticationService.createUser(method: AuthMethod.apple);
  }

  @override
  Widget build(BuildContext context) => CreateAccountView(this);
}
