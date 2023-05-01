import 'package:brine/screens/authentication/onboarding/onboarding_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../services/firebase/authentication/sign_in_with_google.dart';
import '../../../values/regex.dart';
import '../../softener_monitor/softener_monitor_route.dart';
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
        await createAccount(
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

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const SoftenerMonitorRoute(),
          ),
        );
      }
    }
  }

  /// Creates a password-based account with Firebase Auth.
  ///
  /// As part of creating a password-based account with Firebase Auth, a [FirebaseAuthException] can be thrown if
  /// issues with the provided username or password are discovered.
  Future<UserCredential?> createAccount({required String emailAddress, required String password}) async {
    try {
      final UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException thrown during account creation: $e');

      rethrow;
    } catch (e) {
      debugPrint('Creating password-based account failed with exception, $e');

      rethrow;
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
      MaterialPageRoute(
        builder: (BuildContext context) => const OnboardingRoute(),
      ),
    );
  }

  /// Handles taps on the Google sign in button.
  Future<void> handleGoogleCreateAccount() async {
    try {
      await signInWithGoogle();

      // Create the user record in Firebase
      // _createUser();
    } catch (e) {
      debugPrint('Failed to sign in with Google with exception, $e');
    }
  }

  /// Handles taps on the Apple sign in button.
  Future<void> handleAppleCreateAccount() async {
    // TODO create account with Apple
  }

  @override
  Widget build(BuildContext context) => CreateAccountView(this);
}
