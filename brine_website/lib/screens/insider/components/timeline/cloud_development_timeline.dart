import 'package:brinemonitor/screens/insider/components/timeline/models/timeline_item.dart';
import 'package:brinemonitor/screens/insider/components/timeline/models/timeline_item_status.dart';
import 'package:brinemonitor/screens/insider/components/timeline/timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A timeline for the development of the Brine's cloud backend infrastructure.
class CloudDevelopmentTimeline extends StatelessWidget {
  const CloudDevelopmentTimeline({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectTimeline(
      items: [
        TimelineItem(
          title: AppLocalizations.of(context).identifyServiceProvider,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 3),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).configureServices,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 3),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).implementAuthentication,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 3),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).createCloudAPIs,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 4),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).finalizeDatabaseSchema,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 4),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).implementAnalytics,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 5),
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
