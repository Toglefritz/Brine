import 'dart:async';

import 'package:brine/theme/insets.dart';
import 'package:brinemonitor/values/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A stateful widget to create an animated notification
///
/// The notification includes a title, a message, and an icon
class AnimatedNotification extends StatefulWidget {
  const AnimatedNotification({
    super.key,
    required this.width,
    required this.title,
    required this.message,
  });

  /// The width of the preview notification.
  final double width;

  /// Title to be displayed in the notification
  final String title;

  /// Message to be displayed in the notification
  final String message;

  @override
  AnimatedNotificationState createState() => AnimatedNotificationState();
}

/// State class of the AnimatedNotification Widget
///
/// It creates an AnimationController to control the drop-down animation
class AnimatedNotificationState extends State<AnimatedNotification> with SingleTickerProviderStateMixin {
  /// AnimationController to control the drop-down animation
  late AnimationController controller;

  /// Animation of type Offset for moving the widget vertically
  late Animation<Offset> offset;

  /// A timer used to show the emulated notification on an interval.
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();

    /// Initialize controller with a duration of 2 seconds
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    /// Initialize offset with start and end points for the drop-down animation
    offset = Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -1.0)).animate(controller);

    _hide();

    // Show the notification periodically
    _notificationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      _present();
    });
  }

  /// Show the notification
  ///
  /// Starts the controller for the animation
  void _present() {
    controller.forward();

    Future.delayed(const Duration(seconds: 1), () {
      _hide();
    });
  }

  /// Hide the notification
  ///
  /// Reverses the controller for the animation
  void _hide() {
    controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SlideTransition(
        position: offset,
        child: Padding(
          padding: const EdgeInsets.only(top: 35),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          width: widget.width,
          child: Padding(
            padding: const EdgeInsets.all(Insets.xSmall),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          Asset.brineLogo.path,
                          width: 20,
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: Insets.xSmall,
                          ),
                          child: Text(
                            AppLocalizations.of(context).brine.toUpperCase(),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      AppLocalizations.of(context).now,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: Insets.xSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(widget.message),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    controller.dispose();
    super.dispose();
  }
}
