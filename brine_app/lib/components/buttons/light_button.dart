import 'package:flutter/material.dart';

import '../../screens/authentication/onboarding/onboarding_view.dart';
import '../../theme/insets.dart';

/// A button appearing on the [OnboardingView].
class LightButton extends StatelessWidget {
  /// Creates anm [LightButton].
  ///
  /// This widget uses, at its base, an [ElevatedButton] widget. The text displayed on the button is determined by the
  /// [text] field. When it is tapped, the widget calls the function provided by the [onPressed] field. By default,
  /// the button has a width of 350 logical pixels. However, this value can be overridden by the [width] field. An
  /// icon can be optionally displayed on the left side of the button by providing [IconData] to the [icon] field.
  /// If this field is null, no icon is displayed on the button.
  const LightButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.width,
    this.icon,
    this.color,
  });

  /// The text displayed on the button.
  final String text;

  /// A method called when the button is tapped.
  final VoidCallback onPressed;

  /// The width, in logical pixels, of the button.
  ///
  /// If the [width] field is null, the button's width is defaulted to 350 logical pixels.
  final double? width;

  /// A widget used as an icon displayed on the left side of the button.
  final Widget? icon;

  /// The color of the boarder, text, and icon.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 350,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          side: BorderSide(
            color: color ?? Theme.of(context).primaryColorDark,
          ),
          backgroundColor: Theme.of(context).primaryColorLight,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.all(Insets.small),
                child: icon,
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: icon != null ? 24 + Insets.small * 2 : 0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Insets.small,
                  ),
                  child: Text(
                    text.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: color ?? Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
