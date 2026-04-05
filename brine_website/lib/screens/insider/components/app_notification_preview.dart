import 'package:flutter/material.dart';

import '../../../app_preview/brine_device.dart';
import '../../../app_preview/light_theme_data.dart';
import '../../../app_preview/softener_monitor_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../../values/assets.dart';
import 'animated_notification.dart';

/// Provides a preview of the experience of receiving a push notification from the Brine mobile app by running the app
/// itself, which is included as a submodule, inside an iPhone frame mockup.
///
/// The push notification within this preview is mocked up using a custom widget designed to emulate the appearance and
/// behavior of a native push notification.
class AppNotificationPreview extends StatefulWidget {
  /// Creates an instance of [AppNotificationPreview].
  const AppNotificationPreview({
    required this.width,
    super.key,
  });

  /// Determines the width of the screen used to preview the mobile application.
  final double width;

  @override
  State<AppNotificationPreview> createState() => _AppNotificationPreviewState();
}

class _AppNotificationPreviewState extends State<AppNotificationPreview> {
  /// The height of the appliance used in the [SoftenerMonitorView] as a demonstration.
  static const double _applianceHeight = 1000;

  /// The salt level value to use for the [SoftenerMonitorView] as a demonstration.
  final double _saltLevel = 0.07;

  /// The salt distance value to use for the [SoftenerMonitorView] as a demonstration.
  final double _saltDistance = _applianceHeight * _applianceHeight;

  /// The battery level value to use for the [SoftenerMonitorView] as a demonstration.
  final double _batteryLevel = 0.8;

  /// A widget that emulates the appearance of a push notification.
  late AnimatedNotification _notificationWidget;

  /// Gets a notification widget for use in simulating the experience of receiving a push notification about salt
  /// running low from the Brine mobile app.
  void _buildNotificationWidget() {
    _notificationWidget = AnimatedNotification(
      width: widget.width * 0.85,
      title: AppLocalizations.of(context)!.saltLevelLow,
      message: '${AppLocalizations.of(context)!.currentSaltLevel} ${(_saltLevel * 100).round()}%.',
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
              child: SoftenerMonitorView(
                device: BrineDevice(
                  name: 'Brine Device',
                  deviceId: 'slick_demo_device',
                  saltDistance: _saltDistance,
                  saltLevel: _saltLevel,
                  batteryLevel: _batteryLevel,
                  retrievalTimestamp: DateTime.now(),
                  applianceHeight: _applianceHeight,
                  lastUpdatedTimestamp: DateTime.now(),
                ),
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
