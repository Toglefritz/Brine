import 'package:brinemonitor/services/analytics/analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../values/insets.dart';
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
class ThanksController extends State<ThanksRoute> with SingleTickerProviderStateMixin {
  /// A controller for the much bigger and grander confetti effect triggered when the visitor successfully signs
  /// up for updates from Brine.
  late ConfettiController partyController;

  /// Counts the number of times the confetti party has been launched.
  int _confettiCount = 0;

  @override
  void initState() {
    if (kDebugMode == false) {
      FirebaseAnalytics.instance.logScreenView(screenName: 'thanks_page');
    }

    initializeConfettiAnimation();

    // Fire the confetti after a short delay
    Future.delayed(const Duration(milliseconds: 250), () {
      partyController.play();
    });

    super.initState();
  }

  /// Initializes the controllers for the decorative confetti animations.
  ///
  /// The [ConfettiController]s are initialized with [Duration]s that determines the duration of their
  /// confetti animations.
  void initializeConfettiAnimation() {
    setState(() {
      partyController = ConfettiController(duration: const Duration(seconds: 2));
    });
  }

  /// Handles taps on the [PrimaryCTAButton] on the [ThanksView].
  void onButtonPressed() {
    Analytics.logEvent(
      name: 'thanks_cta_pressed',
    );

    context.pushReplacement(InsiderRoute.screenName);
  }

  /// Fires the [ConfettiCannon]s again because everybody loves confetti (except the people who have to clean it
  /// up after the party).
  void repeatParty() {
    Analytics.logEvent(
      name: 'repeat_party',
      parameters: {
        'confetti_count': _confettiCount,
      },
    );

    if (partyController.state != ConfettiControllerState.playing && _confettiCount < 8) {
      _confettiCount++;

      partyController.play();
    } else if (_confettiCount > 8) {
      SnackBar snackBar = SnackBar(
        content: Text(
          AppLocalizations.of(context).enoughConfetti,
          textAlign: TextAlign.center,
          style: GoogleFonts.changaOne().copyWith(
            fontSize: 28,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: Insets.large,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) => ThanksView(this);
}
