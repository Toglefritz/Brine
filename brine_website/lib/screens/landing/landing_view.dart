import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:confetti/confetti.dart';

import '../../components/app_bar/main_app_bar.dart';
import '../../values/insets.dart';
import 'components/footer.dart';
import 'components/bill_nye_gif.dart';
import 'components/icon_animated_button.dart';
import 'landing_controller.dart';

/// View for the [OnboardingRoute].

class LandingView extends StatelessWidget {
  final LandingController state;

  const LandingView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        confettiCallback: () => state.launchConfettiBlast(),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: insetsLarge),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      right: insetsGiant,
                      bottom: insetsLarge,
                      left: insetsGiant,
                    ),
                    child: Text(
                      AppLocalizations.of(context).landingPageTitle,
                      style: GoogleFonts.changaOne().copyWith(
                        fontSize: 42,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: insetsLarge),
                    child: BillNyeGif(),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 800,
                    ),
                    child: Text(
                      AppLocalizations.of(context).landingPageHook,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(insetsXLarge),
                    child: IconAnimatedButton(
                      iconSpacing: state.animatedPaddingValue,
                      startAnimationCallback: state.startPaddingAnimation,
                      stopAnimationCallback: state.stopPaddingAnimation,
                      onTap: state.letsGoooooooo,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 800,
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: <TextSpan>[
                          TextSpan(
                            text: AppLocalizations.of(context).landingPageDescription1,
                          ),
                          TextSpan(
                            text: AppLocalizations.of(context).smart,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          TextSpan(
                            text: AppLocalizations.of(context).landingPageDescription2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: insetsLarge),
                    child: Footer(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 150,
            child: ConfettiWidget(
              maximumSize: const Size(10, 10),
              minimumSize: const Size(5, 5),
              shouldLoop: false,
              confettiController: state.confettiController,
              blastDirection: 2.61799,
              blastDirectionality: BlastDirectionality.directional,
              maxBlastForce: 100,
              minBlastForce: 8,
              emissionFrequency: 1,
              gravity: 1,
            ),
          ),
        ],
      ),
    );
  }
}
