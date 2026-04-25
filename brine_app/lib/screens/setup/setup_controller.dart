import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../services/analytics/analytics.dart';
import '../../services/authentication/exceptions/authentication_exception.dart';
import '../../services/device_management/device_management_service.dart';
import '../../services/device_management/models/brine_device.dart';
import '../../services/push_notifications/push_notifications_service.dart';
import '../errors/error_route.dart';
import '../errors/models/error_type.dart';
import '../softener_monitor/softener_monitor_route.dart';
import '../welcome/welcome_route.dart';
import 'setup_route.dart';
import 'setup_view.dart';

/// Controller for the [SetupRoute].
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
    List<BrineDevice>? deviceList;

    try {
      deviceList = await _getDevices();
    } on AuthenticationException catch (e, s) {
      debugPrint('Failed to perform setup with authentication exception, $e');

      await FirebaseCrashlytics.instance.recordError('Failed to perform setup with authentication exception, $e', s);

      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const ErrorRoute(
            errorType: ErrorType.unauthenticated,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Failed to perform setup with generic exception, $e');

      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const ErrorRoute(
            errorType: ErrorType.unknown,
          ),
        ),
      );
    }

    // If there are no devices on the account, go to the [WelcomeRoute]
    if (deviceList == null || deviceList.isEmpty) {
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const WelcomeRoute(),
        ),
      );
    }
    // If there is at least one device on the account, go to the [SoftenerMonitorRoute].
    else {
      // Go to the water softener monitor route
      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) => SoftenerMonitorRoute(
              devices: deviceList!,
            ),
          ),
        );
      }
    }
  }

  /// Sends the device's FCM token to Firebase to ensure it is up to date.
  Future<void> _sendDeviceTokenToFirebase() async {
    // Currently, push notifications are only supported on iOS and Android.
    if (!(Platform.isIOS || Platform.isAndroid)) {
      return;
    }

    try {
      final PushNotificationsService pushNotificationsService = PushNotificationsService(
        user: FirebaseAuth.instance.currentUser!,
      );

      await pushNotificationsService.registerFcmToken();
    } catch (e) {
      debugPrint('Failed to send FCM token to Firebase with exception: $e');
    }
  }

  /// First, gets a list of [BrineDevice]s on the users account. Second, for each device on the user's account, get the
  /// salt and battery levels of the device.
  Future<List<BrineDevice>> _getDevices() async {
    debugPrint(
      'Getting devices for user, ${FirebaseAuth.instance.currentUser?.uid}',
    );

    try {
      // Get the current user.
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw AuthenticationException('No current user for the authentication session.');
      }

      // Get an instance of the device management service for the current user.
      final DeviceManagementService deviceManagementService = DeviceManagementService(user: user);

      // Get the device's on the user's account.
      final List<BrineDevice> deviceList = await deviceManagementService.getUserDevices();

      return deviceList;
    } on AuthenticationException catch (e, s) {
      debugPrint('Failed to get devices with authentication exception, $e; $s');

      await FirebaseCrashlytics.instance.recordError('Failed to get devices with authentication exception, $e', s);

      rethrow;
    } catch (e) {
      debugPrint('Failed to get devices with exception, $e, of type ${e.runtimeType}');

      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) => SetupView(this);
}
