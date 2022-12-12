import 'package:brine/models/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';
import '../../../values/strings.dart';

/// A button appearing on the [OnboardingView].
class OnboardingButton extends StatelessWidget {
  const OnboardingButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            width: 4.0,
            color: ColorLibrary.primaryDefault,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Insets.small),
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              color: ColorLibrary.primaryDefault,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
