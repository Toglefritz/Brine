import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/light_button.dart';
import '../../../models/unit_of_measurement.dart';
import '../../../theme/insets.dart';
import '../../../values/image_asset.dart';
import '../brine_installation/brine_installation_route.dart';
import 'appliance_measurement_controller.dart';

/// View for [BrineInstallationRoute].
class ApplianceMeasurementView extends StatelessWidget {
  /// Creates an instance of [ApplianceMeasurementView].
  const ApplianceMeasurementView(this.state, {super.key});

  /// A controller for this view.
  final ApplianceMeasurementController state;

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
                    AppLocalizations.of(context)!.heightMeasurementTitle,
                    style: GoogleFonts.bungee().copyWith(
                      fontSize: 52,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // TODO(Toglefritz): update instructions
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  vertical: Insets.medium,
                ),
                sliver: SliverToBoxAdapter(
                  child: Image.asset(
                    ImageAsset.waterSoftener.path,
                    width: 200,
                    height: 200,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Insets.medium,
                      ),
                      child: SizedBox(
                        width: 350,
                        child: TextField(
                          controller: state.measurementFieldController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.waterSoftenerHeight,
                            labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                            // A dropdown menu allowing the unit of measurement to be selected
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(
                                right: Insets.medium,
                              ),
                              child: DropdownButton<UnitOfMeasurement>(
                                value: state.unitOfMeasurement,
                                items: UnitOfMeasurement.values
                                    .map<DropdownMenuItem<UnitOfMeasurement>>(
                                      (UnitOfMeasurement unit) => DropdownMenuItem<UnitOfMeasurement>(
                                        value: unit,
                                        child: Text(unit.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: state.onUnitOfMeasurementChanged,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => state.onHeightSubmitted,
                        ),
                      ),
                    ),
                    LightButton(
                      text: AppLocalizations.of(context)!.saveText,
                      onPressed: state.onHeightSubmitted,
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
