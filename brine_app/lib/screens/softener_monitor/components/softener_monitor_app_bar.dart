import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../services/device_management/models/brine_device.dart';
import '../softener_monitor_controller.dart';
import '../softener_monitor_route.dart';

/// An app bar for views within the [SoftenerMonitorRoute].
class SoftenerMonitorAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an instance of [SoftenerMonitorAppBar].
  SoftenerMonitorAppBar({
    required this.state,
    super.key,
  });

  /// The controller for the view.
  final SoftenerMonitorController state;

  @override
  Size get preferredSize => const Size.fromHeight(50);

  /// A controller for the [MenuAnchor] widget.
  final MenuController _menuAnchorController = MenuController();

  /// Handles changes in the selected device.
  ///
  /// This menu contains a [MenuAnchor] that displays a list of devices on the user's account. The user can select a
  /// device from this list to view information about that device. This function handles changes in the selected device
  /// by closing the menu and then updating the selected device in the controller.
  void _onDeviceSelected(BrineDevice device) {
    _menuAnchorController.close();

    state.onDeviceSelected(device);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        if (state.widget.devices.length > 1)
          MenuAnchor(
            controller: _menuAnchorController,
            menuChildren: List.generate(
              state.widget.devices.length,
              (int index) {
                final BrineDevice device = state.widget.devices[index];

                return MenuItemButton(
                  onPressed: () => _onDeviceSelected(device),
                  child: ListTile(
                    leading: Icon(
                      Icons.circle,
                      size: 12,
                      color: device == state.selectedDevice ? Theme.of(context).primaryColor : Colors.transparent,
                    ),
                    title: Text(
                      device.name.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              },
            ),
            builder: (BuildContext context, _, __) {
              return TextButton(
                onPressed: () {
                  if (_menuAnchorController.isOpen) {
                    _menuAnchorController.close();
                  } else {
                    _menuAnchorController.open();
                  }
                },
                child: RichText(
                  text: TextSpan(
                    text: '${AppLocalizations.of(context)!.device}: ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold,
                        ),
                    children: [
                      TextSpan(
                        text: state.selectedDevice.name.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).primaryColorDark,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        PopupMenuButton<String>(
          onSelected: (String value) => state.onAccountTap(),
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).primaryColorDark,
          ),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: AppLocalizations.of(context)!.account,
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.account),
                ),
              ),
            ];
          },
        ),
      ],
    );
  }
}
