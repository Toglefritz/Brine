import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../components/app_bar/main_app_bar.dart';
import '../../components/footer/footer.dart';
import '../../components/layout/padded_column.dart';
import '../../components/responsive_safe_scaffold.dart';
import '../../values/insets.dart';
import 'components/app_preview.dart';
import 'components/benefits_info.dart';
import 'components/device_info.dart';
import 'components/icon_animated_button_horizontal.dart';
import 'landing_controller.dart';
import 'landing_route.dart';

/// View for the [LandingRoute].
class LandingViewDesktop extends StatelessWidget {
  /// The [LandingController] that manages the state of this view.
  final LandingController state;

  /// Creates an instance of [LandingViewDesktop].
  const LandingViewDesktop(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSafeScaffold(
      appBar: MainAppBar(
        confettiCallback: state.launchConfettiBlast,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: Insets.large,
                    bottom: Insets.medium,
                    left: Insets.large,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: Insets.medium,
                            top: Insets.medium,
                          ),
                          child: PaddedColumn(
                            childrenPadding: Insets.large,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.landingPageTitle,
                                style: GoogleFonts.changaOne().copyWith(
                                  fontSize: 42,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                AppLocalizations.of(context)!.landingPageHook,
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              IconAnimatedButtonHorizontal(
                                text: AppLocalizations.of(context)!
                                    .getStartedButton,
                                onTap: () => state.letsGoooooooo('button_1'),
                              ),
                              Text(
                                AppLocalizations.of(context)!
                                    .landingPageDescription,
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: AppPreview(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Insets.xLarge,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return BenefitsInfo(
                        direction: Axis.horizontal,
                        itemWidth:
                            (constraints.maxWidth - (Insets.small * 3)) / 5,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Insets.medium,
                  ),
                  child: DeviceInfo(
                    direction: MediaQuery.of(context).size.width > 1000
                        ? Axis.horizontal
                        : Axis.vertical,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: Insets.small,
                    bottom: Insets.large,
                  ),
                  child: const Footer(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
