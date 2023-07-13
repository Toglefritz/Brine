import 'package:flutter/material.dart';

/// A [Row] in which each widget in the [children] will be interleaved with [Padding] that has horizontal spacing of
/// [childrenPadding].
///
/// This widget can be used as a direct replacement for a [Row] widget so that padding can be applied to every
/// element in the padding with the [childrenPadding] parameter rather than having to wrap each child in a
/// [Padding] widget.
class PaddedRow extends StatelessWidget {
  const PaddedRow({
    super.key,
    required this.childrenPadding,
    required this.children,
    this.mainAxisAlignment,
  });

  /// The padding to apply between children.
  final double childrenPadding;

  /// A list of widgets to display in the [Row].
  final List<Widget> children;

  /// Determines the way tha the [children] are arranged in the [Row].
  final MainAxisAlignment? mainAxisAlignment;

  /// Returns a [List<Widget>] in which each widget in the
  List<Widget> getPaddedChildren() {
    List<Widget> paddedWidgets = [];

    Padding padding = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: childrenPadding,
      ),
    );

    for (int i = 0; i < children.length; i++) {
      paddedWidgets.add(children[i]);
      paddedWidgets.add(padding);
    }

    return paddedWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
      children: getPaddedChildren(),
    );
  }
}
