import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Presents a button that represents the primary CTA on a page. The button uses the theme's background color as its
/// background color, with a border, and at a high elevation.
class PrimaryCTAButton extends StatelessWidget {
  const PrimaryCTAButton({
    super.key,
    required this.onTap,
    required this.text,
  });

  /// The action to perform when the button is pressed.
  final Function() onTap;

  /// The text to display on the button.
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        elevation: 8,
        backgroundColor: Theme.of(context).primaryColor,
        side: BorderSide(
          color: Theme.of(context).primaryColorDark,
          width: 2.0,
        ),
      ),
      child: SizedBox(
        width: 400,
        child: Text(
          text,
          style: GoogleFonts.changaOne().copyWith(
            fontSize: 36,
            color: Theme.of(context).primaryColorDark,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}