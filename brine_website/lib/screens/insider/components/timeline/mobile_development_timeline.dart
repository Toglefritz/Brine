import 'package:brinemonitor/screens/insider/components/timeline/models/timeline_item.dart';
import 'package:brinemonitor/screens/insider/components/timeline/models/timeline_item_status.dart';
import 'package:brinemonitor/screens/insider/components/timeline/timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A timeline for the development of the Brine mobile app.
class MobileDevelopmentTimeline extends StatelessWidget {
  const MobileDevelopmentTimeline({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectTimeline(
      items: [
        TimelineItem(
          title: AppLocalizations.of(context).wireframesAndPrototypes,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 4),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).architecturalDesign,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 4),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).frameworkSetup,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 4),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).implementAuthentication,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 5),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).incorporateCloudAPIs,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 5),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).developCoreFeatures,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 5),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).implementAnalytics,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 5),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).automatedTestSetup,
          status: TimelineItemStatus.inProgress,
          timestamp: DateTime(2023, 8),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).appStoresApproval,
          status: TimelineItemStatus.incomplete,
          timestamp: DateTime(2023, 9),
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