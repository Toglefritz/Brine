import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/primary_cta_button.dart';

/// A CTA button with an icon on either side.
class IconAnimatedButtonHorizontal extends StatefulWidget {
  const IconAnimatedButtonHorizontal({
    super.key,
    required this.onTap,
  });

  /// The action performed when the CTA button is tapped.
  final Function() onTap;

  @override
  State<IconAnimatedButtonHorizontal> createState() => _IconAnimatedButtonHorizontalState();
}

class _IconAnimatedButtonHorizontalState extends State<IconAnimatedButtonHorizontal>
    with SingleTickerProviderStateMixin {
  /// A controller for the primary CTA button animation.
  late AnimationController _animationController;

  /// An [Animation] used for the primary CTA button animation.
  late Animation<double> _paddingAnimation;

  /// Determines the maximum and minimum extents of the padding values applied to the icons in this widget by the
  /// [_paddingAnimation]. Adjusting this value adjusts the amplitude of the animation.
  final RangeValues _amplitude = const RangeValues(16, 32);

  /// The padding value between the primary CTA buttons and the icons that surround it.
  late double _animatedPaddingValue;

  @override
  void initState() {
    // Initialize the animation controller.
    _animatedPaddingValue = _amplitude.start;
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
    _paddingAnimation = Tween<double>(begin: _amplitude.start, end: _amplitude.end).animate(_animationController)
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
      _animatedPaddingValue = _amplitude.start;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FaIcon(
          FontAwesomeIcons.handPointRight,
          size: 42,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _animatedPaddingValue,
          ),
          child: MouseRegion(
            onEnter: _startPaddingAnimation,
            onExit: _stopPaddingAnimation,
            child: PrimaryCTAButton(
              onTap: widget.onTap,
              text: AppLocalizations.of(context).getStartedButton,
            ),
          ),
        ),
        const FaIcon(
          FontAwesomeIcons.handPointLeft,
          size: 42,
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
