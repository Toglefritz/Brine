import 'package:brinemonitor/screens/insider/components/timeline/models/timeline_item.dart';
import 'package:brinemonitor/screens/insider/components/timeline/models/timeline_item_status.dart';
import 'package:brinemonitor/screens/insider/components/timeline/timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A timeline for the development of the Brine's business resources, systems, and processes.
class BusinessDevelopmentTimeline extends StatelessWidget {
  const BusinessDevelopmentTimeline({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectTimeline(
      items: [
        TimelineItem(
          title: AppLocalizations.of(context).brandingStrategy,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 2),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).incorporateLLC,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 3),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).createWebsite,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 7),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).campaignPreparation,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 8),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).preLaunchCampaign,
          status: TimelineItemStatus.done,
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