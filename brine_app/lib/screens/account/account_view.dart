import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/buttons/light_button.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.account),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Insets.large),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // The user's initials inside a circular avatar.
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
