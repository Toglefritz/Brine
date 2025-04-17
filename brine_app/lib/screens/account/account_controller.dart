import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../l10n/app_localizations.dart';
import '../../services/analytics/analytics.dart';
import '../../services/authentication/authentication_service.dart';
import '../../services/device_management/device_management_service.dart';
import '../../services/device_management/models/brine_device.dart';
import '../welcome/welcome_route.dart';
import 'account_route.dart';
import 'account_view.dart';
import 'edit_profile_view.dart';

/// Controller for the [AccountRoute].
class AccountController extends State<AccountRoute> {
  /// A convenience getter for the Firebase Auth user object.
  User? get user => FirebaseAuth.instance.currentUser;

  /// A key for the form used to edit the user's profile.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// A controller for the field used to edit the user's display name.
  final TextEditingController displayNameController = TextEditingController();

  /// A controller for the field used to edit the user's email address.
  final TextEditingController emailController = TextEditingController();

  /// A controller for the field used to change the user's password.
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    // Set the initial values for the profile editing form.
    _setInitialFormValues();

    super.initState();
  }

  /// Sets the initial values for the profile editing form.
  void _setInitialFormValues() {
    displayNameController.text = user?.displayName ?? '';
    emailController.text = user?.email ?? '';
  }

  /// A convenience getter for the user's initials.
  String get userInitials {
    if (user == null) {
      return '';
    }

    // Split the user's display name their first and last names.
    final List<String> nameParts = user!.displayName!.split(' ');

    // Get the first letter of the user's first name.
    final String firstName = nameParts.first;

    // Get the first letter of the user's last name, if it exists.
    final String lastName = nameParts.length > 1 ? nameParts.last : '';

    // Return a string consisting of the first letters of the user's first and last names.
    return '${firstName[0]}${lastName[0]}';
  }

  /// Determines if the user is currently editing their profile.
  bool _isEditingProfile = false;

  /// Handles taps on the back button.
  void onBack() {
    Analytics.trackEvent(eventName: 'account_back_button_tapped');

    Navigator.of(context).pop();
  }

  /// Handles taps on the button used to edit a user's profile. This function triggers the display of the edit profile
  /// page, allowing the user to update their profile information.
  void onEditProfile() {
    Analytics.trackEvent(eventName: 'edit_profile_button_tapped');

    setState(() {
      _isEditingProfile = true;
    });
  }

  /// Handles taps on the button used to cancel editing a user's profile. This function triggers the display of the
  /// account page without saving any changes made to the user's profile.
  void onCancelEditProfile() {
    Analytics.trackEvent(eventName: 'cancel_edit_profile_button_tapped');

    // TODO(Toglefritz): Confirm cancellation if unsaved changes exist.

    setState(() {
      _isEditingProfile = false;
    });
  }

  /// Handles taps on the button used to save changes to a user's profile.
  Future<void> onSaveProfile() async {
    Analytics.trackEvent(eventName: 'save_profile_button_tapped');

    // Validate the form.
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Save the form.
    formKey.currentState!.save();

    // Determines if any failures occurred while updating any part of the user's profile.
    bool hasFailed = false;

    // If the display name, email, or password have been changed, re-authenticate the user before modifying their
    // account.
    if (displayNameController.text != user!.displayName ||
        emailController.text != user!.email ||
        passwordController.text.isNotEmpty) {
      try {
        await _reauthenticateUser();
      } catch (e) {
        debugPrint('Failed to re-authenticate user with exception: $e');

        // Show an error SnackBar as long as the widget is still mounted.
        if (mounted) {
          _showProfileUpdateFailedSnackBar(AppLocalizations.of(context)!.reauthenticationFailed);
        }

        hasFailed = true;

        return;
      }
    }

    // If the user changed their display name, update the user's display name.
    if (user!.displayName != displayNameController.text) {
      Analytics.trackEvent(eventName: 'display_name_changed');

      try {
        await user!.updateDisplayName(displayNameController.text);

        debugPrint('Successfully updated display name to ${displayNameController.text}');
      } catch (e) {
        debugPrint('Failed to update display name with exception, $e');

        // Show an error SnackBar as long as the widget is still mounted.
        if (mounted) {
          _showProfileUpdateFailedSnackBar(AppLocalizations.of(context)!.displayNameUpdateFailed);
        }

        hasFailed = true;
      }
    }

    // If the user has changed their email address, update the user's email address.
    if (user!.email != emailController.text) {
      Analytics.trackEvent(eventName: 'email_changed');

      try {
        await user!.verifyBeforeUpdateEmail(emailController.text);

        // Show a dialog informing the user that their email will be updated once they confirm the change via the link
        // sent to their new email address.
        if (mounted) {
          await EditProfileView.showEmailChangeConfirmationDialog(context: context, newEmail: emailController.text);
        }

        debugPrint('Successfully updated email to ${emailController.text}');
      } catch (e) {
        debugPrint('Failed to update email with exception, $e');

        // Show an error SnackBar as long as the widget is still mounted.
        if (mounted) {
          _showProfileUpdateFailedSnackBar(AppLocalizations.of(context)!.emailUpdateFailed);
        }

        hasFailed = true;
      }
    }

    // If the user has changed their password, update the user's password.
    if (passwordController.text.isNotEmpty) {
      Analytics.trackEvent(eventName: 'password_changed');

      try {
        await user!.updatePassword(passwordController.text);

        debugPrint('Successfully updated password');
      } catch (e) {
        debugPrint('Failed to update password with exception, $e');

        // Show an error SnackBar as long as the widget is still mounted.
        if (mounted) {
          _showProfileUpdateFailedSnackBar(AppLocalizations.of(context)!.passwordUpdateFailed);
        }

        hasFailed = true;
      }
    }

    // If none of the profile updates failed, display a success SnackBar.
    if (!hasFailed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profileUpdateSuccess),
        ),
      );
    }

    // Disable editing mode.
    setState(() {
      _isEditingProfile = false;
    });
  }

  /// Re-authenticates the user before modifying their account.
  Future<void> _reauthenticateUser() async {
    try {
      AuthCredential credential;

      // Get the current user's authentication provider
      final String providerId = user!.providerData.first.providerId;

      if (providerId == EmailAuthProvider.PROVIDER_ID) {
        // User signed in with email/password - request current password
        credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: passwordController.text, // Ensure the user enters their current password
        );
      } else if (providerId == GoogleAuthProvider.PROVIDER_ID) {
        // User signed in with Google - use Google Sign-In to obtain a credential
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          throw FirebaseAuthException(
            code: 'google-sign-in-cancelled',
            message: 'Google sign-in was canceled.',
          );
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      } else if (providerId == AppleAuthProvider.PROVIDER_ID) {
        // TODO(Toglefritz): Implement Apple Sign-In re-authentication
        throw FirebaseAuthException(
          code: 'reauthentication-failed',
          message: 'Apple Sign-In re-authentication is not yet supported.',
        );
      } else {
        throw FirebaseAuthException(
          code: 'reauthentication-failed',
          message: 'Unsupported authentication method. Please sign in again.',
        );
      }

      // Re-authenticate the user
      await user!.reauthenticateWithCredential(credential);
    } catch (e) {
      debugPrint('Failed to re-authenticate user with exception: $e');

      rethrow;
    }
  }

  /// Shows a [SnackBar] to the user when an update to their profile fails.
  void _showProfileUpdateFailedSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  /// Handles requests to remove a device from an account.
  ///
  /// This function first presents a dialog to the user to confirm that they wish to remove the Brine device from their
  /// account. If they choose the affirmative option, the device is removed from the account using a request to a
  /// Firebase Functions endpoint.
  Future<void> removeDevice(String deviceId) async {
    // Present a dialog to the user to confirm that they wish to remove the device.
    final bool? didConfirm = await AccountView.showRemoveDeviceConfirmationDialog(
      context: context,
      deviceId: deviceId,
    );

    // If the user confirmed that they wish to remove the device, remove the device.
    if (didConfirm ?? false) {
      // Get the current user.
      final User user = FirebaseAuth.instance.currentUser!;

      // Remove the device from the user's account.
      try {
        await DeviceManagementService(user: user).removeDeviceFromAccount(deviceId: deviceId);
      } catch (e) {
        debugPrint('Failed to remove device with exception, $e');

        // TODO(Toglefritz): Handle the failure to remove the device from the account.
      }

      // Create a new list of devices that excludes the device that was removed.
      final List<BrineDevice> updatedDevices = widget.devices
        ..removeWhere((BrineDevice device) => device.deviceId == deviceId);

      // If the user has just removed the last device from their account, navigate back to the WelcomeRoute.
      if (updatedDevices.isEmpty) {
        if (!mounted) return;
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const WelcomeRoute(),
          ),
          (Route<dynamic> route) => false,
        );
        return;
      }
      // Otherwise, refresh this route.
      else {
        // Refresh this route.
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => AccountRoute(devices: updatedDevices),
          ),
        );
      }
    }
  }

  /// Handles taps on the "logout" button.
  Future<void> logout() async {
    Analytics.trackLogout();

    await AuthenticationService.signOut();
  }

  /// Allows a user to delete their account.
  ///
  /// This function first presents a dialog to the user to confirm that they wish to delete their account. If they
  /// choose the affirmative option, the account is deleted using a request to a Firebase Functions endpoint.
  /// Additionally, the user's document in the Firestore collection is deleted. Finally, the user is signed out.
  // TODO(Toglefritz): Disconnect Brine devices from WiFi
  Future<void> deleteAccount() async {
    // Present a dialog to the user to confirm that they wish to delete their account.
    final bool? didConfirm = await AccountView.showDeleteAccountConfirmationDialog(context: context);

    // If the user confirmed that they wish to delete their account, delete the account.
    if (didConfirm ?? false) {
      // Delete the user's document in the Firestore collection.
      try {
        await AuthenticationService(user: user!).deleteUserDocument();
      } catch (e) {
        debugPrint('Failed to delete user document with exception, $e');

        return;
      }

      // Delete the user's account.
      try {
        await user?.delete();
      } catch (e) {
        debugPrint('Failed to delete account with exception, $e');

        // TODO(Toglefritz): Handle the failure to delete the user's account.

        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isEditingProfile ? EditProfileView(this) : AccountView(this),
    );
  }
}
