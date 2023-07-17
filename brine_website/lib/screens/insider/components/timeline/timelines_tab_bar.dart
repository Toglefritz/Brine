import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../values/insets.dart';

/// The [InsiderView] displays several timelines for the Brine project with each timeline representing a different
/// area of the project. Each area is presented as a separate [ProjectTimeline] and the visitor can select the
/// [ProjectTimeline] to view by selecting the different tabs in the [TimelinesTabBar].
class TimelinesTabBar extends StatelessWidget {
  const TimelinesTabBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      indicatorColor: Theme.of(context).primaryColorDark,
      labelStyle: GoogleFonts.shareTechMono().copyWith(
        color: Theme.of(context).primaryColorDark,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      labelPadding: EdgeInsets.symmetric(
        horizontal: Insets.small,
        vertical: Insets.xSmall,
      ),
      dividerColor: Colors.transparent,
      unselectedLabelStyle: GoogleFonts.shareTechMono().copyWith(
        color: Theme.of(context).primaryColorDark,
        fontSize: 16,
      ),
      labelColor: Theme.of(context).primaryColorDark,
      tabs: [
        Tab(text: AppLocalizations.of(context).electronics),
        Tab(text: AppLocalizations.of(context).firmwareDevelopment),
        Tab(text: AppLocalizations.of(context).cloudDevelopment),
        Tab(text: AppLocalizations.of(context).mobileDevelopment),
        Tab(text: AppLocalizations.of(context).businessDevelopment),
      ],
    );
  }
}
