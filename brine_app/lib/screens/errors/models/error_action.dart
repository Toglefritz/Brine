import 'package:flutter/material.dart';

/// Represents an action that can be taken for a specific error type.
class ErrorAction {
  /// Creates an instance of [ErrorAction].
  const ErrorAction({
    required this.label,
    required this.onPressed,
  });

  /// The text to display on the action button.
  final String label;

  /// The callback to execute when the button is pressed.
  final VoidCallback onPressed;
}
