import 'package:brinemonitor/values/insets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/primary_cta_button.dart';

/// A CTA button with an icon on either side.
class IconAnimatedButtonVertical extends StatefulWidget {
  const IconAnimatedButtonVertical({
    super.key,
    required this.onTap,
  });

  /// The action performed when the CTA button is tapped.
  final Function() onTap;

  @override
  State<IconAnimatedButtonVertical> createState() => _IconAnimatedButtonVerticalState();
}

class _IconAnimatedButtonVerticalState extends State<IconAnimatedButtonVertical> with SingleTickerProviderStateMixin {
  /// A controller for the primary CTA button animation.
  late AnimationController _animationController;

  /// An [Animation] used for the primary CTA button animation.
  late Animation<double> _paddingAnimation;

  /// Determines the maximum padding that will be applied by the [_paddingAnimation]. Adjusting this value has the
  /// effect of controlling the amplitude of the icons' movement.
  final double _amplitude = 24;

  /// The under the icons surrounding the primary CTA button.
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

    super.initState();
  }

  /// Initializes the [AnimationController] and the [Animation] for the primary CTA button.
  ///
  /// This method creates a [Tween} to animate between 16 and 24. The [addListener] callback is used to rebuild the widget
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

  /// Starts the animation on the primary CTA button.
  void _startPaddingAnimation(PointerEvent details) {
    _animationController.repeat(reverse: true);
  }

  /// Stops the animation on the primary CTA button.
  void _stopPaddingAnimation(PointerEvent details) {
    _animationController.stop();
    _animationController.reset();
    setState(() {
      _animatedPaddingValue = _amplitude / 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: insetsMedium,
            bottom: _amplitude - _animatedPaddingValue,
            top: _animatedPaddingValue,
          ),
          child: const FaIcon(
            FontAwesomeIcons.solidThumbsUp,
            size: 38,
          ),
        ),
        MouseRegion(
          onEnter: _startPaddingAnimation,
          onExit: _stopPaddingAnimation,
          child: PrimaryCTAButton(
            onTap: widget.onTap,
            text: AppLocalizations.of(context).getStartedButton,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: insetsMedium,
            bottom: _animatedPaddingValue,
            top: _amplitude - _animatedPaddingValue,
          ),
          child: const FaIcon(
            FontAwesomeIcons.solidThumbsUp,
            size: 38,
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
