import 'package:flutter/material.dart';

import '../../../components/loaders/wave_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/insets.dart';
import 'scan_controller.dart';
import 'scan_route.dart';

/// View for the [ScanRoute].
class ScanView extends StatelessWidget {
  /// Creates an instance of [ScanView].
  const ScanView(this.state, {super.key});

  /// A controller for this view.
  final ScanController state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.cancel_outlined,
              color: Theme.of(context).primaryColorDark,
            ),
            onPressed: state.onCancelScan,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            WaveLoader(
              color: Theme.of(context).primaryColorDark,
            ),
            Padding(
              padding: const EdgeInsets.all(
                Insets.small,
              ),
              child: Text(
                AppLocalizations.of(context)!.scanningMessage,
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
