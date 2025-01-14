import 'dart:math';

import 'package:flutter/material.dart';

/// [WaveProgressIndicator] is a widget that displays a linear progress indicator
/// with a wave animation. It takes a [progressPercent] parameter which determines
/// how much of the progress indicator is filled.
class WaveProgressIndicator extends StatefulWidget {
  /// Create an instance of [WaveProgressIndicator].
  const WaveProgressIndicator({
    required this.progressPercent,
    required this.fillColor,
    super.key,
  });

  /// The percentage of progress to be displayed by the progress indicator. This value should be between 0.0 and 1.0,
  /// where 0.0 means no progress, and 1.0 means that the progress is 100% complete.
  final double progressPercent;

  /// The fill color for the progress indication portion of the widget.
  final Color fillColor;

  @override
  WaveProgressIndicatorState createState() => WaveProgressIndicatorState();
}

/// [WaveProgressIndicatorState] is the state class for [WaveProgressIndicator].
/// It holds the [AnimationController] which is used to animate the wave.
class WaveProgressIndicatorState extends State<WaveProgressIndicator> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the wave AnimationController with a duration of 2 seconds
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Create a linear animation for the wave
    // ignore_for_file: prefer_int_literals
    _waveAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );

    // Add listener to the waveController to rebuild when value changes
    _waveController.addListener(() {
      setState(() {});
    });

    // Initialize the progress AnimationController
    _progressController = AnimationController(
      duration: const Duration(
        milliseconds: 500,
      ), // adjust duration for the progress change animation
      vsync: this,
    );

    _progressAnimation = Tween(begin: widget.progressPercent, end: widget.progressPercent).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Add listener to the progressController to rebuild when value changes
    _progressController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(WaveProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the progress value has changed, animate to the new value
    if (widget.progressPercent != oldWidget.progressPercent) {
      _progressAnimation = Tween(begin: oldWidget.progressPercent, end: widget.progressPercent).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
      );

      _progressController
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WavePainter(
        progressPercent: _progressAnimation.value,
        waveAnimationValue: _waveAnimation.value,
        fillColor: widget.fillColor,
      ),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}

/// [WavePainter] is a CustomPainter that is used to draw the wave on the canvas.
/// It takes [progressPercent] which is the progress level and [waveAnimationValue]
/// which is the current value of the wave animation, to draw the wave.
class WavePainter extends CustomPainter {
  /// Creates an instance of [WavePainter].
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
      final double wave = amplitudeFactor * sin((i / size.width) * 2 * pi + 2 * pi * waveAnimationValue);

      // Calculate the height that should not be filled by the progress indicator
      final double unfilledHeight = size.height * (1 - progressPercent);

      // Calculate the total height for the current position, taking into account the wave
      final double totalHeight = wave + unfilledHeight;

      // Calculate the Y position for the current X position in the wave
      final double yPos = size.height - totalHeight;

      // Add the point to the path
      path.lineTo(i.toDouble(), yPos);
    }

    // Close the path and draw it on the canvas
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
