import 'package:brinemonitor/values/insets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../components/primary_color_button.dart';

/// A CTA button with a vertical icon on either side.
class IconAnimatedButtonVertical extends StatefulWidget {
  const IconAnimatedButtonVertical({
    super.key,
    required this.buttonText,
    required this.onTap,
  });

  /// The text to display on the [PrimaryColorButton].
  final String buttonText;

  /// The action performed when the CTA button is tapped.
  final Function() onTap;

  @override
  State<IconAnimatedButtonVertical> createState() => _IconAnimatedButtonVerticalState();
}

class _IconAnimatedButtonVerticalState extends State<IconAnimatedButtonVertical> with TickerProviderStateMixin {
  /// A controller for the primary CTA button animation.
  late AnimationController _animationController;

  /// Provides a callback for each animation frame.
  late final Ticker _ticker;

  /// Determines if the animation should be stopped after the current cycle completes.
  bool _shouldStopOnNextCycle = false;

  /// An [Animation] used for the primary CTA button animation.
  late Animation<double> _paddingAnimation;

  /// Determines the maximum padding that will be applied by the [_paddingAnimation]. Adjusting this value has the
  /// effect of controlling the amplitude of the icons' movement.
  final double _amplitude = 24;

  /// The under the icons surrounding the button.
  late double _animatedPaddingValue;

  @override
  void initState() {
    // Initialize the animation controller.
    _animatedPaddingValue = _amplitude / 2;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _initializeCTAAnimation();

    _ticker = createTicker(_onTick);

    super.initState();
  }

  /// Initializes the [AnimationController] and the [Animation] for the button.
  ///
  /// This method creates a [Tween] to animate between 16 and 24. The [addListener] callback is used to rebuild the widget
  /// tree via the [setState] call inside.
  void _initializeCTAAnimation() {
    super.initState();
    _paddingAnimation = Tween<double>(begin: 0, end: _amplitude).animate(_animationController)
      ..addListener(() {
        setState(() {
          _animatedPaddingValue = _paddingAnimation.value;
        });
      });
  }

  /// A callback called on each animation frame.
  void _onTick(Duration elapsed) {
    double roundedDouble = double.parse(_animationController.value.toStringAsFixed(2));
    // Check if the animation cycle is completed and should be stopped
    if (_shouldStopOnNextCycle && roundedDouble < 0.5) {
      _animationController.stop();
      _ticker.stop();
      _shouldStopOnNextCycle = false;
    }
  }

  /// Starts the animation on the primary button.
  void _startPaddingAnimation(PointerEvent details) {
    _shouldStopOnNextCycle = false;
    _animationController.repeat(reverse: true);
    _ticker.start();
  }

  /// Stops the animation on the primary button.
  void _stopPaddingAnimation(PointerEvent details) {
    _shouldStopOnNextCycle = true;
  }

  /// Listener function for animation status.
  void _animationStatusListener(AnimationStatus status) {
    // When the animation completes a cycle, stop the animation and remove the listener
    if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
      _animationController.stop();
      _animationController.removeStatusListener(_animationStatusListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: Insets.kInsetsMedium,
            bottom: _amplitude - _animatedPaddingValue,
            top: _animatedPaddingValue,
          ),
          child: const FaIcon(
            FontAwesomeIcons.solidThumbsUp,
            size: 36,
          ),
        ),
        MouseRegion(
          onEnter: _startPaddingAnimation,
          onExit: _stopPaddingAnimation,
          child: PrimaryColorButton(
            onPressed: widget.onTap,
            text: widget.buttonText,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: Insets.kInsetsMedium,
            bottom: _animatedPaddingValue,
            top: _amplitude - _animatedPaddingValue,
          ),
          child: const FaIcon(
            FontAwesomeIcons.solidThumbsUp,
            size: 36,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
