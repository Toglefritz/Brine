import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/light_button.dart';
import '../../../extensions/brightness_extensions.dart';
import '../../../theme/insets.dart';
import '../../../values/image_asset.dart';
import 'components/onboarding_legal_prompt.dart';
import 'onboarding_controller.dart';
import 'onboarding_route.dart';

/// View for [OnboardingRoute].
class OnboardingView extends StatelessWidget {
  /// Creates an instance of [OnboardingView].
  const OnboardingView(this.state, {super.key});

  /// A controller for this view.
  final OnboardingController state;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      Theme.of(context).brightness.oppositeSystemOverlayStyle(),
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Insets.large,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.brine,
                          style: GoogleFonts.bungee().copyWith(
                            fontSize: 52,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // TODO(Toglefritz): replace with vector
                      Image.asset(
                        Theme.of(context).brightness == Brightness.light
                            ? ImageAsset.logoTransparentBackground
                            : ImageAsset.logoTransparentBackgroundInverse,
                        width: 200,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Insets.small,
                    ),
                    child: LightButton(
                      onPressed: state.handleLoginTap,
                      text: AppLocalizations.of(context)!.login,
                    ),
                  ),
                  LightButton(
                    onPressed: state.handleCreateAccountTap,
                    text: AppLocalizations.of(context)!.createAnAccount,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(Insets.medium),
                    child: OnboardingLegalPrompt(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
