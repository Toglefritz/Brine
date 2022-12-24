import 'package:brine/models/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';

/// A button appearing on the [OnboardingView].
class OnboardingButton extends StatelessWidget {
  const OnboardingButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
    this.icon,
  }) : super(key: key);

  final String text;
  final VoidCallback onPressed;
  final double? width;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 350,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          side: const BorderSide(
            width: 4.0,
            color: ColorLibrary.primaryDefault,
          ),
          backgroundColor: ColorLibrary.primaryLight,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.all(Insets.small),
                child: Icon(
                  icon,
                  color: ColorLibrary.primaryDefault,
                  size: 24,
                ),
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
                    style: const TextStyle(
                      fontSize: 16,
                      color: ColorLibrary.primaryDefault,
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
