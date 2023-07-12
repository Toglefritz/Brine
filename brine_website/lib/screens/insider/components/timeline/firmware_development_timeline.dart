import 'package:brinemonitor/screens/insider/components/timeline/models/timeline_item.dart';
import 'package:brinemonitor/screens/insider/components/timeline/models/timeline_item_status.dart';
import 'package:brinemonitor/screens/insider/components/timeline/timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A timeline for the development of the Brine device firmware.
class FirmwareDevelopmentTimeline extends StatelessWidget {
  const FirmwareDevelopmentTimeline({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectTimeline(
      items: [
        TimelineItem(
          title: AppLocalizations.of(context).firmwareArchitectureDesign,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 4),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).planTransports,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 4),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).sensorIntegration,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 5),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).backendAPIIntegration,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 5),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).powerManagementSystem,
          status: TimelineItemStatus.inProgress,
          timestamp: DateTime(2023, 5),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).wakeUpRoutines,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 6),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).proofOfPossessionCheck,
          status: TimelineItemStatus.done,
          timestamp: DateTime(2023, 6),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).sensorCalibrationRoutines,
          status: TimelineItemStatus.inProgress,
          timestamp: DateTime(2023, 7),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).bluetoothProvisioningFlow,
          status: TimelineItemStatus.incomplete,
          timestamp: DateTime(2023, 8),
        ),
        TimelineItem(
          title: AppLocalizations.of(context).buildOTASystem,
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
