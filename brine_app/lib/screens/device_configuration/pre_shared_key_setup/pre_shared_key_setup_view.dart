import 'package:flutter/material.dart';

import '../../../components/loaders/wave_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/insets.dart';
import 'pre_shared_key_setup_route.dart';

/// View for the [PreSharedKeySetupRoute].
class PreSharedKeySetupView extends StatelessWidget {
  /// Creates an instance of [PreSharedKeySetupView].
  const PreSharedKeySetupView({super.key});

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
                AppLocalizations.of(context)!.performingPskSetup,
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
