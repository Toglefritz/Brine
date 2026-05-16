part of 'setup_route.dart';

/// Controller for the [SetupRoute].
///
/// Coordinates the initial app setup after authentication. Fetches the user's device list and navigates to the
/// appropriate screen based on whether devices exist on the account.
class SetupController extends State<SetupRoute> {
  @override
  void initState() {
    Analytics.trackPageView('setup');

    // Perform setup for app usage.
    unawaited(_performSetup());

    // Send the device's FCM token to Firebase to ensure it is up to date.
    unawaited(_sendDeviceTokenToFirebase());

    super.initState();
  }

  /// Performs the setup necessary to proceed to the next route. This involves getting a list of the user's devices,
  /// assuming any have been added to the user's account, getting the details for each device, and handling errors
  /// related to these processes. If the user has no devices on their account, the app proceeds to the [WelcomeRoute].
  /// Otherwise, the app goes to the [SoftenerMonitorRoute].
  Future<void> _performSetup() async {
    final List<BrineDevice> deviceList;

    try {
      deviceList = await _getDevices();
    } on AuthenticationException catch (e, s) {
      debugPrint('Failed to perform setup with authentication exception, $e');

      await widget.crashReporter.recordError('Failed to perform setup with authentication exception, $e', s);

      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const ErrorRoute(
            errorType: ErrorType.unauthenticated,
          ),
        ),
      );
      return;
    } catch (e) {
      debugPrint('Failed to perform setup with generic exception, $e');

      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const ErrorRoute(
            errorType: ErrorType.unknown,
          ),
        ),
      );
      return;
    }

    // If there are no devices on the account, go to the [WelcomeRoute]
    if (deviceList.isEmpty) {
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const WelcomeRoute(),
        ),
      );
    }
    // If there is at least one device on the account, go to the [SoftenerMonitorRoute].
    else {
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => SoftenerMonitorRoute(
            devices: deviceList,
          ),
        ),
      );
    }
  }

  /// Sends the device's FCM token to Firebase to ensure it is up to date.
  Future<void> _sendDeviceTokenToFirebase() async {
    // Currently, push notifications are only supported on iOS and Android.
    if (!(Platform.isIOS || Platform.isAndroid)) {
      return;
    }

    try {
      final User? user = widget.authSession.currentUser;
      if (user == null) return;

      final PushNotificationsService pushNotificationsService =
          widget.pushNotificationsServiceFactory?.call(user) ?? PushNotificationsService(user: user);

      await pushNotificationsService.registerFcmToken();
    } catch (e) {
      debugPrint('Failed to send FCM token to Firebase with exception: $e');
    }
  }

  /// Fetches the list of [BrineDevice]s on the user's account using the injected [AuthSession] and
  /// [DeviceManagementService] factory.
  Future<List<BrineDevice>> _getDevices() async {
    final User? user = widget.authSession.currentUser;

    debugPrint('Getting devices for user, ${user?.uid}');

    if (user == null) {
      throw AuthenticationException('No current user for the authentication session.');
    }

    try {
      final DeviceManagementService deviceManagementService =
          widget.deviceManagementServiceFactory?.call(user) ?? DeviceManagementService(user: user);

      final List<BrineDevice> deviceList = await deviceManagementService.getUserDevices();

      return deviceList;
    } on AuthenticationException catch (e, s) {
      debugPrint('Failed to get devices with authentication exception, $e; $s');

      await widget.crashReporter.recordError('Failed to get devices with authentication exception, $e', s);

      rethrow;
    } catch (e) {
      debugPrint('Failed to get devices with exception, $e, of type ${e.runtimeType}');

      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) => SetupView(this);
}
