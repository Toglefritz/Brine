part of 'brine_installation_route.dart';

/// Controller for [BrineInstallationRoute].
class BrineInstallationController extends State<BrineInstallationRoute> {
  @override
  void initState() {
    Analytics.trackPageView('brine_installation');

    super.initState();
  }

  /// Handles taps on the button used by the user to confirm they have completed installation of the Brine device.
  Future<void> onContinue() async {
    Analytics.trackEvent(eventName: 'brine_installation_continue_tap');

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ApplianceMeasurementRoute(
          device: widget.device,
          bleCommunicationManager: widget.bleCommunicationManager,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BrineInstallationView(this);
}
