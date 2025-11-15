import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/device_management/models/brine_device.dart';
import '../../../theme/insets.dart';
import 'expandable_device_card.dart';

/// A widget that displays a list of user's Brine devices in a wrap layout.
class DeviceList extends StatelessWidget {
  /// Creates an instance of [DeviceList].
  const DeviceList({required this.devices, required this.onRemoveDevice, super.key});

  /// The list of devices to display.
  final List<BrineDevice> devices;

  /// Callback function called when a device should be removed.
  /// Takes the device ID as a parameter.
  final void Function(String deviceId) onRemoveDevice;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // A title for the list of the user's devices
        Padding(
          padding: const EdgeInsets.only(top: Insets.large, bottom: Insets.medium),
          child: Text(
            AppLocalizations.of(context)!.brineDevices,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.bold),
          ),
        ),

        // A list of the user's devices, represented as cards
        Wrap(
          children: List.generate(devices.length, (index) {
            final BrineDevice device = devices[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Insets.small),
              child: ExpandableDeviceCard(device: device, onRemoveDevice: () => onRemoveDevice(device.deviceId)),
            );
          }),
        ),
      ],
    );
  }
}
