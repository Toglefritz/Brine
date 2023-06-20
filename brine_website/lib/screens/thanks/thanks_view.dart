import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/app_bar/main_app_bar.dart';
import '../../components/primary_cta_button.dart';
import '../../values/insets.dart';
import '../../components/footer.dart';
import 'components/confetti_cannon.dart';
import 'components/thanks_frog_gif.dart';
import 'thanks_controller.dart';

/// View for the [OnboardingRoute].

class ThanksView extends StatelessWidget {
  final ThanksController state;

  const ThanksView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Builder(
        builder: (context) => Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: insetsLarge),
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: insetsMedium),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 900,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: insetsLarge,
                            ),
                            child: Text(
                              '${AppLocalizations.of(context).thanksPageTitlePrefix} ${state.widget.name}!',
                              style: GoogleFonts.changaOne().copyWith(
                                fontSize: 42,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: insetsLarge),
                            child: ThanksFrogGif(),
                          ),
                          Text(
                            AppLocalizations.of(context).thanksPageDescription,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(insetsLarge),
                            child: PrimaryCTAButton(
                              onTap: state.onButtonPressed,
                              text: AppLocalizations.of(context).accessInsiderPortal,
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
                ),
              ),
            ),
            ConfettiCannon(
              controller: state.partyController,
              blastDirection: 30,
              left: 24,
            ),
            ConfettiCannon(
              controller: state.partyController,
              blastDirection: 150,
              right: 24,
            ),
            ConfettiCannon(
              controller: state.partyController,
              blastDirection: 210,
              right: 24,
              bottom: 24,
            ),
            ConfettiCannon(
              controller: state.partyController,
              blastDirection: 330,
              left: 24,
              bottom: 24,
            ),
          ],
        ),
      ),
    );
  }
}
