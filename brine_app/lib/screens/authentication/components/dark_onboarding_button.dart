import 'package:brine/models/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';

/// A button appearing on the [OnboardingView] with a dark background.
class DarkOnboardingButton extends StatelessWidget {
  /// Creates a [DarkOnboardingButton].
  ///
  /// This widget uses, at its base, an [OutlinedButton] with a dark background color and no border. The text displayed
  /// on the button is determined by the [text] field. By default, the width of the button is 350 logical pixels. This
  /// value can overridden by providing a value for the [width] field. When it is tapped, the [onPressed] method is
  /// called. For asynchronous actions performed after the [onPressed] button is called, the [loading] boolean can be
  /// set to true to indicate that an asynchronous process is in progress. If [loading] is set to true, the [onPressed]
  /// action is not called and a [CircularProgressIndicator] is shown on the left side of the button.
  const DarkOnboardingButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
    this.loading,
  }) : super(key: key);

  /// The text displayed on the button.
  final String text;

  /// A method called when the button is tapped.
  final VoidCallback onPressed;

  /// The width, in logical pixels, of the button.
  ///
  /// If the [width] field is null, the button's width is defaulted to 350 logical pixels.
  final double? width;

  /// Determines if there is a loading process associated with this button.
  final bool? loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 350,
      child: OutlinedButton(
        onPressed: loading == false ? onPressed : null,
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
          child: Row(
            children: [
              if (loading == true)
                const Padding(
                  padding: EdgeInsets.only(left: Insets.small),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: loading == true ? Insets.small + 16 : 0),
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
            ],
          ),
        ),
      ),
    );
  }
}
