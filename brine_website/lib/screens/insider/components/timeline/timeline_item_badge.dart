import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'models/timeline_item.dart';
import 'models/timeline_item_status.dart';

/// A widget that represents a single item in a project timeline.
///
/// The [TimelineItemBadge] is visualized as a circle that changes color depending on the status of the item. The circle
/// can be green, yellow, or red, representing a completed item, an in-progress item, or an item that hasn't yet been
/// started, respectively.
///
/// For completed items, the circle will contain a checkmark icon, while for not-started items it will contain an "X"
/// icon. In-progress items will have a dash icon.
///
/// Each [TimelineItemBadge] also includes a text title.
class TimelineItemBadge extends StatelessWidget {
  const TimelineItemBadge({
    super.key,
    required this.item,
  });

  /// A [TimelineItem]
  final TimelineItem item;

  /// Returns the icon to use for the [TimelineItem]: a checkmark for a completed item, a dash icon for an in-progress
  /// item, and an "X" icon for an incomplete icon.
  Icon _getIcon(BuildContext context) {
    switch (item.status) {
      case TimelineItemStatus.done:
        return const Icon(
          FontAwesomeIcons.check,
          color: Colors.white,
        );
      case TimelineItemStatus.inProgress:
        return const Icon(
          FontAwesomeIcons.minus,
          color: Colors.white,
        );
      case TimelineItemStatus.campaign:
        return const Icon(
          FontAwesomeIcons.crown,
          color: Colors.white,
        );
      default:
        return const Icon(
          FontAwesomeIcons.x,
          color: Colors.white,
        );
    }
  }

  Color? _getColor() {
    switch (item.status) {
      case TimelineItemStatus.done:
        return Colors.green[900];
      case TimelineItemStatus.inProgress:
        return Colors.yellow[900];
      case TimelineItemStatus.campaign:
        return Colors.blue[900];
      default:
        return Colors.red[900];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getColor(),
            border: Border.all(
              color: Theme.of(context).primaryColorDark,
              width: 2.0,
            ),
          ),
          child: Center(
            child: _getIcon(context),
          ),
        ),
        SizedBox(
          width: 120,
          child: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          DateFormat('MMMM yyyy').format(item.timestamp),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
