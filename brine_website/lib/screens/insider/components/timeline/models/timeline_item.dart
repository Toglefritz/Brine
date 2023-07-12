import 'package:brinemonitor/screens/insider/components/timeline/models/timeline_item_status.dart';

/// Represents the data displayed for each [TimelineItemBadge] in the [Timeline] widget.
///
/// Each [TimelineItem] contains three pieces of information used to display [TimelineItem]s in the [Timeline}:
///   - The [title] is a String value displayed as the name of the item.
///   - The [status] is a representation of the completion status of the item.
///   - The [timestamp] represents either the completion date or the expected completion date of the item.
class TimelineItem {
  /// A title used to identify the item.
  final String title;

  /// The completion status of the item, as represented by the [TimelineItemStatus] enum.
  final TimelineItemStatus status;

  /// A [DateTime], from which only the month and year are displayed, to represent either the time when the
  /// item was completed or the expected completion date, depending on the [status] of the item.
  final DateTime timestamp;

  TimelineItem({
    required this.title,
    required this.status,
    required this.timestamp,
  });
}
