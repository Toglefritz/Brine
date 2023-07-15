import 'package:brine/screens/softener_monitor/softener_monitor_route.dart';
import 'package:brine/services/firebase/models/brine_device.dart';
import 'package:brine/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../values/assets.dart';
import 'animated_notification.dart';

/// Provides a preview of the experience of receiving a push notification from the Brine mobile app by running the
/// app itself, which is included as a submodule, inside an iPhone frame mockup.
///
/// The push notification within this preview is mocked up using a custom widget designed to emulate the appearance
/// and behavior of a native push notification.
class AppNotificationPreview extends StatefulWidget {
  const AppNotificationPreview({
    super.key,
    required this.width,
  });

  /// Determines the width of the screen used to preview the mobile application.
  final double width;

  @override
  State<AppNotificationPreview> createState() => _AppNotificationPreviewState();
}

class _AppNotificationPreviewState extends State<AppNotificationPreview> {
  /// The salt level value to use for the [SoftenerMonitorRoute] as a demonstration.
  final double _saltLevel = 0.07;

  /// The battery level value to use for the [SoftenerMonitorRoute] as a demonstration.
  final double _batteryLevel = 0.8;

  /// A widget that emulates the appearance of a push notification.
  late AnimatedNotification _notificationWidget;

  /// Gets a [NotificationWidget] widget for use in simulating the experience of receiving a push notification
  /// about salt running low from the Brine mobile app.
  void _buildNotificationWidget() {
    _notificationWidget = AnimatedNotification(
      width: widget.width * 0.85,
      title: AppLocalizations.of(context).saltLevelLow,
      message: '${AppLocalizations.of(context).currentSaltLevel} ${(_saltLevel * 100).round()}%.',
    );
  }

  @override
  Widget build(BuildContext context) {
    _buildNotificationWidget();

    return Stack(
      alignment: Alignment.center,
      children: [
        // Reference a view from the Brine mobile app
        Theme(
          data: lightThemeData,
          child: SizedBox(
            width: widget.width,
            height: 615,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              child: SoftenerMonitorRoute(
                devices: [
                  BrineDevice(
                    deviceId: 'slick_demo_device',
                    saltLevel: _saltLevel,
                    batteryLevel: _batteryLevel,
                    retrievalTimestamp: DateTime.now(),
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          child: _notificationWidget,
        ),
        Image.asset(
          Asset.iphone13Mockup.path,
          width: 300,
        ),
      ],
    );
  }
}
