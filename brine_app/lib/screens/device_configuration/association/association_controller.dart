part of 'association_route.dart';

/// Controller for the [AssociationRoute].
///
/// On initialization, attempts to associate the Brine device with the authenticated user's account via the backend.
/// After a successful (or failed) association, navigates to the [PreSharedKeySetupRoute].
class AssociationController extends State<AssociationRoute> {
  @override
  void initState() {
    // Associate the Brine device to the user's account.
    WidgetsBinding.instance.addPostFrameCallback((_) => _associateDevice());

    super.initState();
  }

  /// Attempt to associate the Brine device with the user's account.
  Future<void> _associateDevice() async {
    try {
      // Get the current user from the injected auth session.
      final User? user = widget.authSession.currentUser;

      if (user == null) {
        debugPrint('No authenticated user available for device association.');
      } else {
        // Add the device to the user's account.
        final DeviceManagementService service =
            widget.deviceManagementServiceFactory?.call(user) ?? DeviceManagementService(user: user);
        await service.addDeviceToAccount(device: widget.device);
      }
    } catch (e) {
      debugPrint('Failed to associate device with exception, $e');

      // TODO(Toglefritz): Handle the failure to add the device to the account.
    }

    // With the device successfully associated, navigate to the next screen.
    if (!mounted) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PreSharedKeySetupRoute(
          bleCommunicationManager: widget.bleCommunicationManager,
          device: widget.device,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AssociationView(this);
}
