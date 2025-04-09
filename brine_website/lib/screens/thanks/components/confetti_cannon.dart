import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// A full-on cannon for firing confetti across the screen.
///
/// Because this composed widget contains a [Positioned] widget, it must be placed inside a [Stack] widget.
class ConfettiCannon extends StatelessWidget {
  /// Creates a [ConfettiCannon] widget.
  const ConfettiCannon({
    required this.controller,
    required this.blastDirection,
    super.key,
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  /// A controller for the [ConfettiWidget].
  final ConfettiController controller;

  /// The direction to fire the confetti effect in degrees, with zero degrees pointing horizontally to the right. The
  /// rotation angle is counterclockwise.
  final int blastDirection;

  /// Determines the positioning of the [ConfettiCannon] widget with respect to the left side of the [Stack] widget
  /// in which the [ConfettiCannon] must reside.
  final double? left;

  /// Determines the positioning of the [ConfettiCannon] widget with respect to the right side of the [Stack] widget
  /// in which the [ConfettiCannon] must reside.
  final double? right;

  /// Determines the positioning of the [ConfettiCannon] widget with respect to the top of the [Stack] widget
  /// in which the [ConfettiCannon] must reside.
  final double? top;

  /// Determines the positioning of the [ConfettiCannon] widget with respect to the bottom of the [Stack] widget
  /// in which the [ConfettiCannon] must reside.
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: ConfettiWidget(
        maximumSize: const Size(20, 20),
        minimumSize: const Size(5, 5),
        confettiController: controller,
        blastDirection: blastDirection * pi / 180,
        maxBlastForce: 80,
        minBlastForce: 40,
        emissionFrequency: 1,
        gravity: 1,
      ),
    );
  }
}
