import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/light_button.dart';
import '../../../theme/insets.dart';
import 'brine_installation_controller.dart';
import 'brine_installation_route.dart';

/// View for [BrineInstallationRoute].
class BrineInstallationView extends StatelessWidget {
  /// Creates an instance of [BrineInstallationView].
  const BrineInstallationView(this.state, {super.key});

  /// A controller for this view.
  final BrineInstallationController state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Insets.medium,
          ),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Insets.small,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    AppLocalizations.of(context)!.installationTitle,
                    style: GoogleFonts.bungee().copyWith(
                      fontSize: 52,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.symmetric(
                  vertical: Insets.medium,
                ),
                sliver: SliverToBoxAdapter(
                  // TODO(Toglefritz): add Brine installation instructions
                  child: Icon(Icons.square_foot),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LightButton(
                      text: AppLocalizations.of(context)!.continueText,
                      onPressed: state.onContinue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
