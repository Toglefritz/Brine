import 'package:brine/models/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';

/// A button appearing on the [OnboardingView] with a dark background.
class DarkOnboardingButton extends StatelessWidget {
  const DarkOnboardingButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
  }) : super(key: key);

  final String text;
  final VoidCallback onPressed;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 250,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: ColorLibrary.primaryDefault,
          side: const BorderSide(
            width: 4.0,
            color: ColorLibrary.primaryDefault,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Insets.small,
          ),
          child: Text(
            text.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
