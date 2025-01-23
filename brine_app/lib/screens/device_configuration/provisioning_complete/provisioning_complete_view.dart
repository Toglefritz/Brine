import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/buttons/light_button.dart';
import '../../../theme/insets.dart';
import 'provisioning_complete_controller.dart';
import 'provisioning_complete_route.dart';

/// View for [ProvisioningCompleteRoute].
class ProvisioningCompleteView extends StatelessWidget {
  /// Creates an instance of [ProvisioningCompleteView].
  const ProvisioningCompleteView(this.state, {super.key});

  /// A controller for this view.
  final ProvisioningCompleteController state;

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
                    AppLocalizations.of(context)!.setupComplete,
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
                  child: Icon(
                    Icons.check,
                    size: 128,
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LightButton(
                      text: AppLocalizations.of(context)!.done,
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
