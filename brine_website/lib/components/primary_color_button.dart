import 'package:flutter/material.dart';

import '../values/insets.dart';

/// Presents a button that represents the primary CTA on a page. The button uses the theme's background color as its
/// background color, with a border, and at a high elevation.
class PrimaryColorButton extends StatelessWidget {
  const PrimaryColorButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  /// The action to perform when the button is pressed.
  final Function() onPressed;

  /// The text to display on the button.
  final String text;

  @override
  Widget build(BuildContext context) {
    Color themeColor = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).primaryColorDark
        : Theme.of(context).primaryColorLight;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        side: BorderSide(
          color: themeColor,
          width: 2.0,
        ),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Insets.kInsetsSmall,
          ),
          child: Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 22,
                  color: themeColor,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
