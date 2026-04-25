import 'package:flutter/material.dart';

import '../../../components/loaders/wave_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/insets.dart';
import 'device_connection_controller.dart';
import 'device_connection_route.dart';

/// View for the [DeviceConnectionRoute].
class DeviceConnectionView extends StatelessWidget {
  /// Creates an instance of [DeviceConnectionView].
  const DeviceConnectionView(this.state, {super.key});

  /// A controller for this view.
  final DeviceConnectionController state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            WaveLoader(
              color: Theme.of(context).primaryColorDark,
            ),
            Padding(
              padding: const EdgeInsets.all(
                Insets.medium,
              ),
              child: Text(
                AppLocalizations.of(context)!.bleConnecting,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).primaryColorDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
