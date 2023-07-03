import 'dart:math';

import 'package:flutter/material.dart';

/// [WaveProgressIndicator] is a widget that displays a linear progress indicator
/// with a wave animation. It takes a [progressPercent] parameter which determines
/// how much of the progress indicator is filled.
class WaveProgressIndicator extends StatefulWidget {
  const WaveProgressIndicator({
    super.key,
    required this.progressPercent,
  });

  /// The percentage of progress to be displayed by the progress indicator. This value should be between 0.0 and 1.0,
  /// where 0.0 means no progress, and 1.0 means that the progress is 100% complete.
  final double progressPercent;

  @override
  WaveProgressIndicatorState createState() => WaveProgressIndicatorState();
}

/// [WaveProgressIndicatorState] is the state class for [WaveProgressIndicator].
/// It holds the [AnimationController] which is used to animate the wave.
class WaveProgressIndicatorState extends State<WaveProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: WavePainter(
            progressPercent: widget.progressPercent,
            waveAnimationValue: _controller.value,
            fillColor: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// [WavePainter] is a CustomPainter that is used to draw the wave on the canvas.
/// It takes [progressPercent] which is the progress level and [waveAnimationValue]
/// which is the current value of the wave animation, to draw the wave.
class WavePainter extends CustomPainter {
  WavePainter({
    required this.progressPercent,
    required this.waveAnimationValue,
    required this.fillColor,
  });

  /// The percentage of progress to be displayed by the progress indicator. This value should be between 0.0 and 1.0,
  /// where 0.0 means no progress, and 1.0 means that the progress is 100% complete.
  final double progressPercent;

  /// The current value of the wave animation. This value typically changes over time, resulting in the wave effect in
  /// the progress indicator.
  final double waveAnimationValue;

  /// The color that is used to fill the progress indicator.
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();

    // Factor for controlling the amplitude of the wave
    final double amplitudeFactor = 5.0 + (5 * sin(2 * pi * waveAnimationValue));

    path.moveTo(0, size.height);
    for (int i = 0; i <= size.width.toInt(); i++) {
      // Calculate the sine wave for current position
      double wave = amplitudeFactor * sin((i / size.width) * 2 * pi + 2 * pi * waveAnimationValue);

      // Calculate the height that should not be filled by the progress indicator
      double unfilledHeight = size.height * (1 - progressPercent);

      // Calculate the total height for the current position, taking into account the wave
      double totalHeight = wave + unfilledHeight;

      // Calculate the Y position for the current X position in the wave
      double yPos = size.height - totalHeight;

      // Add the point to the path
      path.lineTo(i.toDouble(), yPos);
    }

    // Close the path and draw it on the canvas
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
