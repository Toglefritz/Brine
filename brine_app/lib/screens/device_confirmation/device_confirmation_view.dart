import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/light_button.dart';
import '../../theme/insets.dart';
import 'device_confirmation_controller.dart';
import 'device_confirmation_route.dart';

/// View for [DeviceConfirmationRoute].
class DeviceConfirmationView extends StatelessWidget {
  /// Creates an instance of [DeviceConfirmationView].
  const DeviceConfirmationView(this.state, {super.key});

  /// A controller for this view.
  final DeviceConfirmationController state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Insets.small,
          ),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Insets.medium,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    AppLocalizations.of(context)!.deviceDetected,
                    style: GoogleFonts.bungee().copyWith(
                      fontSize: 52,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  vertical: Insets.small,
                  horizontal: Insets.xLarge,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    AppLocalizations.of(context)!.detectedDeviceConfirmation,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).primaryColorDark,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  vertical: Insets.small,
                  horizontal: Insets.medium,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    state.widget.device.name?.substring(6) ?? state.widget.device.address,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 52,
                          color: Theme.of(context).brightness == Brightness.light
                              ? Theme.of(context).primaryColorDark
                              : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: Insets.xSmall,
                        bottom: Insets.small,
                      ),
                      child: LightButton(
                        text: AppLocalizations.of(context)!.continueText,
                        onPressed: state.onContinuePressed,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: Insets.xSmall,
                        bottom: Insets.medium,
                      ),
                      child: LightButton(
                        text: AppLocalizations.of(context)!.chooseAnother,
                        onPressed: state.onChooseAnotherPressed,
                      ),
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
