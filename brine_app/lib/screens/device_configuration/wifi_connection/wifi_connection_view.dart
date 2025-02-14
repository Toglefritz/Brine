import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/loaders/wave_loader.dart';
import '../../../theme/insets.dart';
import 'wifi_connection_controller.dart';
import 'wifi_connection_route.dart';

/// View for [WiFiConnectionRoute].
class WiFiConnectionView extends StatelessWidget {
  /// Creates an instance of [WiFiConnectionView].
  const WiFiConnectionView(this.state, {super.key});

  /// A controller for this view.
  final WiFiConnectionController state;

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
                AppLocalizations.of(context)!.wifiConnecting,
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
