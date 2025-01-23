import 'package:flutter/material.dart';

import 'dashed_line_painter.dart';

/// A widget that draws a horizontal dashed divider line.
///
/// The [DashedDivider] widget creates a horizontal line with a dashed pattern, which can be customized by specifying
/// the dash width, dash gap, stroke width, and color.
class DashedDivider extends StatelessWidget {
  /// The height of the divider.
  final double height;

  /// The width of each dash segment.
  final double dashWidth;

  /// The gap between each dash segment.
  final double dashGap;

  /// The width of the divider stroke.
  final double strokeWidth;

  /// The color of the dashed divider.
  final Color color;

  /// Creates a dashed divider with the given properties.
  ///
  /// The [height] specifies the height of the divider.
  /// The [dashWidth] specifies the width of each dash segment.
  /// The [dashGap] specifies the gap between each dash segment.
  /// The [strokeWidth] specifies the width of the divider stroke.
  /// The [color] specifies the color of the dashed divider.
  const DashedDivider({
    super.key,
    this.height = 1.0,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
    this.strokeWidth = 1.0,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: DashedLinePainter(
        dashWidth: dashWidth,
        dashGap: dashGap,
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}
