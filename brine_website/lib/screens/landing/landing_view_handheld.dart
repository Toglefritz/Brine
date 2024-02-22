import 'package:brinemonitor/screens/landing/components/app_preview.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/app_bar/main_app_bar.dart';
import '../../components/footer.dart';
import '../../components/padded_column.dart';
import '../../components/responsive_safe_scaffold.dart';
import '../../values/insets.dart';
import 'components/benefits_info.dart';
import 'components/device_info.dart';
import 'components/icon_animated_button_horizontal.dart';
import 'landing_controller.dart';

/// View for the [LandingRoute].
class LandingViewHandheld extends StatelessWidget {
  final LandingController state;

  const LandingViewHandheld(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveSafeScaffold(
      appBar: MainAppBar(
        confettiCallback: () => state.launchConfettiBlast(),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(
                Insets.medium,
              ),
              child: PaddedColumn(
                childrenPadding: Insets.large,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Insets.medium),
                    child: Text(
                      AppLocalizations.of(context).landingPageTitle,
                      style: GoogleFonts.changaOne().copyWith(
                        fontSize: 42,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Center(
                    child: AppPreview(),
                  ),
                  Text(
                    AppLocalizations.of(context).landingPageHook,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  IconAnimatedButtonHorizontal(
                    text: AppLocalizations.of(context).getStartedButton,
                    onTap: () => state.letsGoooooooo('button_1'),
                  ),
                  Text(
                    AppLocalizations.of(context).landingPageDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const BenefitsInfo(
                    direction: Axis.vertical,
                    itemWidth: 512,
                  ),
                  const DeviceInfo(
                    direction: Axis.vertical,
                  ),
                  const Footer(),
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
