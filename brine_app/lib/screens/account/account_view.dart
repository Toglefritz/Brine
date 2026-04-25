import 'package:flutter/material.dart';

import '../../components/buttons/light_button.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/insets.dart';
import 'account_controller.dart';
import 'account_route.dart';
import 'components/device_list.dart';
import 'components/user_avatar.dart';

/// View for the [AccountRoute].
class AccountView extends StatelessWidget {
  /// Creates an instance of [AccountView].
  const AccountView(this.state, {super.key});

  /// A controller for this view.
  final AccountController state;

  /// A dialog presented to the user when they attempt to remove a Brine device from their account.
  static Future<bool?> showRemoveDeviceConfirmationDialog({
    required BuildContext context,
    required String deviceId,
  }) async {
    final bool? removeDevice = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.removeDevice),
          content: Text(AppLocalizations.of(context)!.removeDeviceConfirmation(deviceId)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(AppLocalizations.of(context)!.remove),
            ),
          ],
        );
      },
    );

    return removeDevice;
  }

  /// A dialog presented to the user to confirm that they wish to delete their account.
  static Future<bool?> showDeleteAccountConfirmationDialog({required BuildContext context}) async {
    final bool? removeDevice = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteAccount),
          content: Text(AppLocalizations.of(context)!.deleteAccountConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(AppLocalizations.of(context)!.delete),
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
        title: Text(AppLocalizations.of(context)!.account),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: state.onBack),
        actions: [IconButton(icon: const Icon(Icons.edit_outlined), onPressed: state.onEditProfile)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Insets.large),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // User avatar - either profile picture or initials
                UserAvatar(
                  user: state.user,
                ),

                // The user's name
                if (state.user?.displayName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: Insets.small),
                    child: Text(state.user?.displayName ?? '', style: Theme.of(context).textTheme.headlineSmall),
                  ),

                // The user's email address
                Padding(
                  padding: const EdgeInsets.only(top: Insets.xSmall),
                  child: Text(state.user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
                ),

                // List of user's devices
                DeviceList(devices: state.widget.devices, onRemoveDevice: state.removeDevice),

                // A title for a section of controls for managing the user's account.
                Padding(
                  padding: const EdgeInsets.only(top: Insets.medium),
                  child: Text(
                    AppLocalizations.of(context)!.accountControls,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Logout button
                Padding(
                  padding: const EdgeInsets.only(
                    top: Insets.small,
                    bottom: Insets.medium,
                    left: Insets.medium,
                    right: Insets.medium,
                  ),
                  child: LightButton(
                    text: AppLocalizations.of(context)!.logout,
                    onPressed: state.logout,
                  ),
                ),

                // Delete account button
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: Insets.medium,
                    left: Insets.medium,
                    right: Insets.medium,
                  ),
                  child: LightButton(
                    text: AppLocalizations.of(context)!.deleteAccount,
                    color: Colors.red[900],
                    onPressed: state.deleteAccount,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
