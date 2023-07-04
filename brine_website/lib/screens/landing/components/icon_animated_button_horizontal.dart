import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../components/light_button.dart';

/// A CTA button with an icon on either side.
///
/// This widget is pretty cool TBH. It consists of a [LightButton] in the center of two icons, a left and right
/// pointing hand that point towards the button. When the button is hovered, the icons animate back and forth
/// horizontally, as if gesturing to the button. After the cursor leaves the [MouseRegion] used to trigger this
/// animation effect, the animation is allowed to complete its current cycle before stopping.
///
/// The [hideLeftIcon] boolean can be optionally supplied to determine if the left icon should be hidden. Hiding the
/// left icon helps to avoid overflows on smaller screens.
class IconAnimatedButtonHorizontal extends StatefulWidget {
  const IconAnimatedButtonHorizontal({
    super.key,
    required this.text,
    required this.onTap,
  });

  /// The text displayed in the button.
  final String text;

  /// The action performed when the CTA button is tapped.
  final Function() onTap;

  @override
  State<IconAnimatedButtonHorizontal> createState() => _IconAnimatedButtonHorizontalState();
}

class _IconAnimatedButtonHorizontalState extends State<IconAnimatedButtonHorizontal> with TickerProviderStateMixin {
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

    _startPaddingAnimation();

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

  /// Starts the animation on the primary button.
  void _startPaddingAnimation() {
    _animationController.repeat(reverse: true);
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
            child: LightButton(
              onPressed: widget.onTap,
              text: widget.text,
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
