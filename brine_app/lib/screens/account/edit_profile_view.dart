import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/insets.dart';
import 'account_controller.dart';
import 'account_route.dart';

/// View for the [AccountRoute] when the user is editing their profile.
class EditProfileView extends StatelessWidget {
  /// Creates an instance of [EditProfileView].
  const EditProfileView(this.state, {super.key});

  /// A controller for this view.
  final AccountController state;

  /// Shows a dialog to the user informing them that they need to accept the confirmation send via email to their new
  /// email address before the change will be applied.
  static Future<bool?> showEmailChangeConfirmationDialog({
    required BuildContext context,
    required String newEmail,
  }) async {
    final bool? removeDevice = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.emailUpdateDialogTitle),
          content: Text(AppLocalizations.of(context)!.emailUpdateDialogMessage(newEmail)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );

    return removeDevice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editAccount),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: state.onCancelEditProfile,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Insets.medium),
            child: GestureDetector(
              onTap: state.onSaveProfile,
              child: Chip(
                label: Text(
                  AppLocalizations.of(context)!.save,
                  style: const TextStyle(color: Colors.black), // Always black on primary color
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Insets.large,
            horizontal: Insets.xxLarge,
          ),
          child: Center(
            child: Form(
              key: state.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // If the user has a profile picture, display it here.
                  if (state.user?.photoURL != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(state.user!.photoURL!),
                    )
                  // Otherwise, display the user's initials inside a circular avatar.
                  else
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF212121), // Always dark color on primary
                          width: 2,
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Insets.medium),
                        child: Text(
                          state.userInitials,
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            color: const Color(0xFF212121), // Always dark color on primary
                          ),
                        ),
                      ),
                    ),

                  // A title for the profile settings section
                  Padding(
                    padding: const EdgeInsets.only(top: Insets.large),
                    child: Text(
                      AppLocalizations.of(context)!.profile,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // A text field for the user to enter their display name. By default, the text field is populated with
                  // the user's current display name.
                  TextFormField(
                    controller: state.displayNameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.displayName,
                    ),
                    validator: (value) {
                      // Confirm that the display name is not empty.
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.displayNameRequired;
                      }

                      return null;
                    },
                  ),

                  // A text field for the user to enter their email address. By default, the text field is populated
                  // with the user's current email address.
                  Padding(
                    padding: const EdgeInsets.only(top: Insets.medium),
                    child: TextFormField(
                      controller: state.emailController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.email,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        // Confirm that the email address is not empty.
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.emailRequired;
                        }
                        // Confirm that the entry is a valid email address
                        else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return AppLocalizations.of(context)!.emailInvalid;
                        }

                        return null;
                      },
                    ),
                  ),
                  // A title for a section allowing the user to change their password.
                  Padding(
                    padding: const EdgeInsets.only(top: Insets.xLarge),
                    child: Text(
                      AppLocalizations.of(context)!.security,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // A form field for the user to enter a new password.
                  TextFormField(
                    controller: state.passwordController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.newPassword,
                      prefix: const Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
