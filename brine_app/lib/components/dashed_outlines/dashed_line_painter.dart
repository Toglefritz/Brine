import 'package:flutter/rendering.dart';

import 'dashed_divider.dart';

/// A custom painter that draws a horizontal dashed line.
///
/// The [DashedLinePainter] is used by the [DashedDivider] widget to paint the dashed line.
class DashedLinePainter extends CustomPainter {
  /// The width of each dash segment.
  final double dashWidth;

  /// The gap between each dash segment.
  final double dashGap;

  /// The width of the stroke.
  final double strokeWidth;

  /// The color of the dashed line.
  final Color color;

  /// Creates a dashed line painter with the given properties.
  ///
  /// The [dashWidth] specifies the width of each dash segment.
  /// The [dashGap] specifies the gap between each dash segment.
  /// The [strokeWidth] specifies the width of the stroke.
  /// The [color] specifies the color of the dashed line.
  DashedLinePainter({
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final path = Path();

    while (startX < size.width) {
      path
        ..moveTo(startX, size.height / 2)
        ..lineTo(startX + dashWidth, size.height / 2);
      startX += dashWidth + dashGap;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
