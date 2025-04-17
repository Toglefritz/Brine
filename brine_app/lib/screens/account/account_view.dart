import 'package:flutter/material.dart';

import '../../components/buttons/light_button.dart';
import '../../l10n/app_localizations.dart';
import '../../services/device_management/models/brine_device.dart';
import '../../theme/insets.dart';
import 'account_controller.dart';
import 'account_route.dart';
import 'components/expandable_device_card.dart';

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
      builder: (BuildContext context) {
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
  static Future<bool?> showDeleteAccountConfirmationDialog({
    required BuildContext context,
  }) async {
    final bool? removeDevice = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: state.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: state.onEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Insets.large),
          child: Center(
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

                // The user's name
                Padding(
                  padding: const EdgeInsets.only(top: Insets.small),
                  child: Text(
                    state.user?.displayName ?? '',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),

                // The user's email address
                Text(
                  state.user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                if (state.widget.devices.isNotEmpty) ...[
                  // A title for the list of the user's devices
                  Padding(
                    padding: const EdgeInsets.only(
                      top: Insets.large,
                      bottom: Insets.medium,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.brineDevices,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),

                  // A list of the user's devices, represented as cards
                  Wrap(
                    children: List.generate(
                      state.widget.devices.length,
                      (index) {
                        final BrineDevice device = state.widget.devices[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Insets.small,
                          ),
                          child: ExpandableDeviceCard(
                            device: device,
                            onRemoveDevice: () => state.removeDevice(device.deviceId),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // A title for a section of controls for managing the user's account.
                Padding(
                  padding: const EdgeInsets.only(top: Insets.large),
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
                  padding: const EdgeInsets.all(Insets.medium),
                  child: LightButton(
                    text: AppLocalizations.of(context)!.logout,
                    onPressed: state.logout,
                  ),
                ),

                // Delete account button
                Padding(
                  padding: const EdgeInsets.only(bottom: Insets.medium),
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
