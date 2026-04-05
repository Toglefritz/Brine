import 'package:flutter/material.dart';

/// A [Column] in which each widget in the [children] will be interleaved with [Padding] that has vertical spacing of
/// [childrenPadding].
///
/// This widget can be used as a direct replacement for a [Column] widget so that padding can be applied to every
/// element in the padding with the [childrenPadding] parameter rather than having to wrap each child in a [Padding]
/// widget.
class PaddedColumn extends StatelessWidget {
  /// Creates an instance of [PaddedColumn].
  const PaddedColumn({
    required this.childrenPadding,
    required this.children,
    super.key,
    this.mainAxisAlignment,
  });

  /// The padding to apply between children.
  final double childrenPadding;

  /// A list of widgets to display in the [Column].
  final List<Widget> children;

  /// Determines the way tha the [children] are arranged in the [Column].
  final MainAxisAlignment? mainAxisAlignment;

  /// Returns a [List<Widget>] in which each widget in the in the list is wrapped in a [Padding] widget with vertical
  /// padding of [childrenPadding].
  List<Widget> _getPaddedChildren() {
    final List<Widget> paddedWidgets = [];

    final Padding padding = Padding(
      padding: EdgeInsets.symmetric(
        vertical: childrenPadding,
      ),
    );

    for (int i = 0; i < children.length; i++) {
      paddedWidgets
        ..add(children[i])
        ..add(padding);
    }

    return paddedWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
      children: _getPaddedChildren(),
    );
  }
}
