import 'package:flutter/material.dart';

import '../../../theme/insets.dart';

/// An [ElevatedButton] with a circular shape and a "+" icon in the center.
class AddDeviceButton extends StatelessWidget {
  /// Creates an instance of [AddDeviceButton].
  const AddDeviceButton({
    required this.onPressed,
    super.key,
  });

  /// The action to perform when the button is pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColorLight),
        shape: WidgetStateProperty.all<CircleBorder>(const CircleBorder()),
        side: WidgetStateProperty.all(
          BorderSide(
            width: 3,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.all(
            Insets.medium,
          ),
        ),
      ),
      child: Icon(
        Icons.add,
        color: Theme.of(context).primaryColorDark,
        size: 64,
      ),
    );
  }
}
