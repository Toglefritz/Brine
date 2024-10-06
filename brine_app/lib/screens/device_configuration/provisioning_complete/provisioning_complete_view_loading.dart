import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../theme/insets.dart';
import 'provisioning_complete_controller.dart';
import 'provisioning_complete_route.dart';
import 'provisioning_complete_view.dart';

/// View for the [ProvisioningCompleteRoute] presented while the provisioning process is finalized.
class ProvisioningCompleteViewLoading extends StatelessWidget {
  /// Creates an instance of [ProvisioningCompleteView].
  const ProvisioningCompleteViewLoading(this.state, {super.key});

  /// A controller for this view.
  final ProvisioningCompleteController state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitWave(
              color: Theme.of(context).primaryColorDark,
            ),
            Padding(
              padding: const EdgeInsets.all(
                Insets.medium,
              ),
              child: Text(
                AppLocalizations.of(context)!.completingSetup,
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
