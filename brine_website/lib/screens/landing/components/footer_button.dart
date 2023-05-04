import 'package:flutter/material.dart';

/// A button appearing in the [Footer].
class FooterButton extends StatelessWidget {
  const FooterButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).primaryColor,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}
