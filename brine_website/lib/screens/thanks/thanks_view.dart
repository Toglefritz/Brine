import 'package:brinemonitor/components/padded_column.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/app_bar/main_app_bar.dart';
import '../../components/light_button.dart';
import '../../components/social_sharing_buttons.dart';
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
              padding: EdgeInsets.symmetric(
                vertical: Insets.kInsetsLarge,
              ),
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Insets.kInsetsMedium,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 900,
                      ),
                      child: PaddedColumn(
                        childrenPadding: Insets.kInsetsMedium,
                        children: <Widget>[
                          Text(
                            '${AppLocalizations.of(context).thanksPageTitlePrefix} ${state.widget.name}!',
                            style: GoogleFonts.changaOne().copyWith(
                              fontSize: 42,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const ThanksFrogGif(),
                          Text(
                            AppLocalizations.of(context).thanksPageDescription,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          SocialSharingButtons(
                            successCallback: () => state.partyController.play(),
                          ),
                          LightButton(
                            onPressed: state.onButtonPressed,
                            text: AppLocalizations.of(context).accessInsiderPortal,
                            width: 350,
                          ),
                          const Footer(),
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
          ],
        ),
      ),
    );
  }
}
