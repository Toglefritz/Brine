import 'package:brinemonitor/values/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/padded_flex.dart';
import '../../../values/insets.dart';
import 'benefits_item.dart';

/// A list of widgets explaining the benefits of using Brine.
class BenefitsInfo extends StatelessWidget {
  const BenefitsInfo({
    super.key,
    required this.direction,
    required this.itemWidth,
  });

  /// The axis along which to arrange the list of widgets.
  final Axis direction;

  /// The width of the [BenefitsItem]s within this widget.
  final double itemWidth;

  @override
  Widget build(BuildContext context) {
    return PaddedFlex(
      direction: direction,
      mainAxisAlignment: MainAxisAlignment.center,
      childrenPadding: Insets.small,
      children: [
        BenefitsItem(
          width: itemWidth,
          icon: Image.asset(
            Asset.waterMinerals.path,
            width: 128,
          ),
          title: AppLocalizations.of(context).reduceScaleBuildup,
          description: AppLocalizations.of(context).reduceScaleBuildupExplanation,
        ),
        BenefitsItem(
          width: itemWidth,
          icon: Image.asset(
            Asset.soapHands.path,
            width: 128,
          ),
          title: AppLocalizations.of(context).increaseCleaningEffectiveness,
          description: AppLocalizations.of(context).increaseCleaningEffectivenessExplanation,
        ),
        BenefitsItem(
          width: itemWidth,
          icon: Image.asset(
            Asset.socks.path,
            width: 128,
          ),
          title: AppLocalizations.of(context).protectClothingAndFabrics,
          description: AppLocalizations.of(context).protectClothingAndFabricsExplanation,
        ),
        BenefitsItem(
          width: itemWidth,
          icon: Image.asset(
            Asset.hair.path,
            width: 128,
          ),
          title: AppLocalizations.of(context).promoteHealthySkinAndHair,
          description: AppLocalizations.of(context).promoteHealthySkinAndHairExplanation,
        ),
      ],
    );
  }
}
