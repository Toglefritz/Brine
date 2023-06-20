import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';

import '../../components/navigable_page_controller.dart';
import '../insider/insider_route.dart';
import 'thanks_route.dart';
import 'thanks_view.dart';

/// Controller for the [ThanksRoute].
///
/// This screen displays for visitors who have signed up to receive updates from Brine, either because they have just
/// completed the signup form presented by [EmailOptinAnimatedDialog] or because, after completing that form and having
/// a flag set via [SharedPreferences] the visitor returns to the site.
///
/// This screen features a big ol' party with a bunch of confetti that displays when the page launches and a very
/// special GIF thanking the visitor for their interest in Brine. The page shows updates about Brine and links
/// to share the project with others.
class ThanksController extends NavigablePageController<ThanksRoute> with SingleTickerProviderStateMixin {
  /// A controller for the much bigger and grander confetti effect triggered when the visitor successfully signs
  /// up for updates from Brine.
  late ConfettiController partyController;

  @override
  void initState() {
    if (kDebugMode == false) {
      FirebaseAnalytics.instance.logEvent(name: 'thanks_page_opened');
    }

    initializeConfettiAnimation();
    partyController.play();

    super.initState();
  }

  /// Initializes the controllers for the decorative confetti animations.
  ///
  /// The [ConfettiController]s are initialized with [Duration]s that determines the duration of their
  /// confetti animations.
  void initializeConfettiAnimation() {
    setState(() {
      partyController = ConfettiController(duration: const Duration(seconds: 1));
    });
  }

  /// Handles taps on the [PrimaryCTAButton] on the [ThanksView].
  void onButtonPressed() {
    // TODO tag

    context.pushReplacement(InsiderRoute.screenName);
  }

  @override
  Widget build(BuildContext context) => ThanksView(this);
}
