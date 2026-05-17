part of 'provisioning_complete_route.dart';

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
            WaveLoader(
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
