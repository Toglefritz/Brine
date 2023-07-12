import 'package:brine/theme/insets.dart';
import 'package:brinemonitor/screens/insider/components/timeline/models/timeline_item.dart';
import 'package:brinemonitor/screens/insider/components/timeline/timeline_item_badge.dart';
import 'package:flutter/material.dart';

/// A horizontally scrollable widget that represents a sequence of timeline items in a project timeline.
///
/// The [ProjectTimeline] widget takes a list of map items where each map represents a single timeline item. Each map item
/// should include a [title] and [status].
///
/// The [status] of each item in the timeline can be "done", "in-progress", or "incomplete," as represented by the
/// [TimelineItemStatus] enum. The status of the item determines the color and the icon of the circle in the
/// [TimelineItemBadge] widget.
///
/// The timeline itself will be oriented horizontally, with horizontal scrolling implemented for when the timeline is
/// too long for the display.
class ProjectTimeline extends StatelessWidget {
  const ProjectTimeline({
    super.key,
    required this.items,
  });

  /// A list of [TimelineItem]s to be displayed in the timeline.
  final List<TimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map<Widget>(
          (item) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Insets.medium,
              ),
              child: TimelineItemBadge(
                item: item,
              ),
            );
          },
        ).toList()
          ..addAll(
            [
              SizedBox(
                height: 64.0,
                child: VerticalDivider(
                  thickness: 2.0,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ],
          ),
      ),
    );
  }
}
