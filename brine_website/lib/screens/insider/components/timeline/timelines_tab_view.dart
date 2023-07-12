import 'package:flutter/material.dart';

import '../../../../values/insets.dart';
import 'business_development_timeline.dart';
import 'cloud_development_timeline.dart';
import 'electronics_timeline.dart';
import 'firmware_development_timeline.dart';
import 'mobile_development_timeline.dart';

/// The [InsiderView] displays several timelines for the Brine project with each timeline representing a different
/// area of the project. Each child of the [TabBarView] shows a timeline for a different area of the project.
class TimelinesTabView extends StatelessWidget {
  const TimelinesTabView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Padding(
        padding: EdgeInsets.only(
          top: Insets.kInsetsLarge,
        ),
        child: const TabBarView(
          children: [
            ElectronicsTimeline(),
            FirmwareDevelopmentTimeline(),
            CloudDevelopmentTimeline(),
            MobileDevelopmentTimeline(),
            BusinessDevelopmentTimeline(),
          ],
        ),
      ),
    );
  }
}
