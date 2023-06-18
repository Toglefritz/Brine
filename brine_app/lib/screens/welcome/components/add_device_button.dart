import 'package:brine/theme/insets.dart';
import 'package:flutter/material.dart';

import '../../../theme/color_library.dart';

/// An [ElevatedButton] with a circular shape and a "+" icon in the center.
class AddDeviceButton extends StatelessWidget {
  const AddDeviceButton({
    super.key,
    required this.onPressed,
  });

  /// The action to perform when the button is pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(ColorLibrary.primaryLight),
        shape: MaterialStateProperty.all<CircleBorder>(const CircleBorder()),
        side: MaterialStateProperty.all(
          const BorderSide(
            width: 3.0,
            color: ColorLibrary.primaryDefault,
          ),
        ),
        padding: MaterialStateProperty.all(
          const EdgeInsets.all(
            Insets.medium,
          ),
        ),
      ),
      child: const Icon(
        Icons.add,
        color: ColorLibrary.primaryDefault,
        size: 64,
      ),
    );
  }
}
