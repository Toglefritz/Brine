import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../values/assets.dart';
import '../../values/insets.dart';
import 'under_construction_controller.dart';
import 'under_construction_route.dart';

/// View for the [UnderConstructionRoute].
///
/// Displays the Brine logo, a short message letting visitors know the site is being refreshed, and a confetti burst to
/// keep things on-brand.
class UnderConstructionView extends StatelessWidget {
  /// The controller that owns the state for this view.
  final UnderConstructionController state;

  /// Creates an instance of [UnderConstructionView].
  const UnderConstructionView(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.large),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: state.launchConfetti,
                      child: Image.asset(
                        Asset.brineLogo.path,
                        width: 120,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: Insets.large),
                    child: Text(
                      AppLocalizations.of(context)!.brine.toUpperCase(),
                      style: GoogleFonts.bungee().copyWith(
                        fontSize: 48,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: Insets.large),
                    child: Text(
                      AppLocalizations.of(context)!.underConstructionMessage,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              maximumSize: const Size(10, 10),
              minimumSize: const Size(5, 5),
              confettiController: state.confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 60,
              minBlastForce: 10,
              emissionFrequency: 0.4,
              numberOfParticles: 20,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
