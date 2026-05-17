part of 'device_connection_route.dart';

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
