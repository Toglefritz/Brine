import 'package:brinemonitor/screens/insider/components/timeline/models/timeline_item.dart';
import 'package:brinemonitor/screens/insider/components/timeline/models/timeline_item_status.dart';
import 'package:brinemonitor/screens/insider/components/timeline/timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A timeline for the development of the Brine electronics.
class ElectronicsTimeline extends StatelessWidget {
  const ElectronicsTimeline({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectTimeline(
      items: [
        TimelineItem(
          title: AppLocalizations.of(context).listCoreFeatures,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 1),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).defineSpecs,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 1),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).exploreHardwareOptions,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 1),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).componentSelection,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 2),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).conceptRenderings,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 3),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).cadPrototypes,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 3),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).breadboardPrototypes,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 4),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).designPCB,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 5),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).assemblePCBPrototypes,
          status: TimelineItemStatus.inProgress,
          timestamp: DateTime(2023, 6),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).testHardwarePrototypes,
          status: TimelineItemStatus.incomplete,
          timestamp: DateTime(2023, 7),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).finalizeElectronicsDesign,
          status: TimelineItemStatus.incomplete,
          timestamp: DateTime(2023, 8),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).crowdfundingCampaign,
          status: TimelineItemStatus.campaign,
          timestamp: DateTime(2023, 9),
        ),
      ],
    );
  }
}
