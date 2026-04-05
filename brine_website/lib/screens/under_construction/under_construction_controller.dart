import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import 'under_construction_route.dart';
import 'under_construction_view.dart';

/// Controller for the [UnderConstructionRoute].
///
/// Coordinates the confetti animation that gives this placeholder page the same playful character as the main landing
/// page. The confetti fires once automatically when the page loads, and visitors can trigger it again by tapping the
/// celebration icon.
class UnderConstructionController extends State<UnderConstructionRoute> {
  /// Controls the decorative confetti burst.
  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Fire a welcome burst after the first frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      confettiController.play();
    });
  }

  /// Launches a confetti blast on demand.
  void launchConfetti() {
    confettiController.play();
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UnderConstructionView(this);
}
