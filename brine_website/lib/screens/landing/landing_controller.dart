import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../../components/navigable_page_controller.dart';
import 'components/signup_dialog/email_optin_animated_dialog.dart';
import 'landing_route.dart';
import 'landing_view.dart';

/// Controller for the [LandingRoute].
///
/// This screen features a [PrimaryCTAButton] surrounded by two FontAwesomeIcons. The [PrimaryCTAButton] is wrapped
/// in a Padding widget that has an animated [EdgeInsets].
///
/// When the mouse hovers over the [PrimaryCTAButton], the horizontal padding value animates from an initial value of
/// 16 to a maximum value of 24 over a duration of 500ms, and then reverses from 24 back to 16 over another 500ms.
/// This hover animation effect is achieved using an [AnimationController] and a [Tween] animation.
///
/// The [MouseRegion] widget surrounding the [PrimaryCTAButton] provides two callbacks: [onEnter] and [onExit]. These
/// callbacks are used to start and stop the padding animation respectively.
class LandingController extends NavigablePageController<LandingRoute> with SingleTickerProviderStateMixin {
  /// A controller for the decorative confetti effect
  late ConfettiController confettiController;

  @override
  void initState() {
    if (kDebugMode == false) {
      FirebaseAnalytics.instance.logAppOpen();
    }

    initializeConfettiAnimation();

    super.initState();
  }

  /// Initializes the controller for the decorative confetti animation.
  ///
  /// The [ConfettiController] is initialized with a [Duration] that determines the duration of the
  /// confetti animation.
  void initializeConfettiAnimation() {
    setState(() {
      confettiController = ConfettiController(duration: const Duration(seconds: 1));
    });
  }

  /// Launches the confetti!
  void launchConfettiBlast() {
    confettiController.play();
  }

  /// Handles taps on the main CTA button on the landing page by TODO ...
  void letsGoooooooo() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'email signup dialog',
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) => const EmailOptinAnimatedDialog(),
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => LandingView(this);
}
