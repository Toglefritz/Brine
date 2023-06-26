import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../../components/navigable_page_controller.dart';
import 'components/signup_dialog/email_optin_animated_dialog.dart';
import 'landing_route.dart';
import 'landing_view_desktop.dart';

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
  /// A controller for the decorative confetti effect launch-able from the main menu.
  late ConfettiController confettiController;

  /// A controller for the much bigger and grander confetti effect triggered when the visitor successfully signs
  /// up for updates from Brine.
  late ConfettiController partyController;

  @override
  void initState() {
    if (kDebugMode == false) {
      FirebaseAnalytics.instance.logAppOpen();
    }

    initializeConfettiAnimation();

    super.initState();
  }

  /// Initializes the controllers for the decorative confetti animations.
  ///
  /// The [ConfettiController]s are initialized with [Duration]s that determines the duration of their
  /// confetti animations.
  void initializeConfettiAnimation() {
    setState(() {
      confettiController = ConfettiController(duration: const Duration(seconds: 1));
      partyController = ConfettiController(duration: const Duration(seconds: 5));
    });
  }

  /// Launches the confetti!
  void launchConfettiBlast() {
    confettiController.play();
  }

  /// Handles taps on the main CTA button on the landing page by showing a dialog allowing the visitor to sign up for
  /// updates about Brine. The [EmailOptinAnimatedDialog] returns a boolean value to indicate whether or not the
  /// ultimate call to add the visitor's information to a Firebase collection succeeded. If the visitor successfully
  /// signs up, we have a little party with lots of confetti and stuff, if not, we get sad and display an error message.
  Future<void> letsGoooooooo() async {
    bool? success = await showGeneralDialog<bool?>(
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

    if(success == true) {
      throwAParty();
    }
  }

  /// Throws a little party to celebrate the visitor successfully signing up for updates from Brine by launching a
  /// bunch of confetti and showing a very special GIF to thank the visitor for signing up.
  ///
  /// While the main view is enjoying a party, this method also saves an entry in [SharedPreferences] to indicate
  /// that the visitor has successfully signed up so that they are presented with a message indicating such on their
  /// next visit to the site.
  void throwAParty() {
    partyController.play();

    setState(() {

    });
  }

  // TODO use different views for different screen sizes
  @override
  Widget build(BuildContext context) => LandingViewDesktop(this);
}
