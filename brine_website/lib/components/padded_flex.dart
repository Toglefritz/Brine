import 'package:flutter/material.dart';

/// A [Flex] in which each widget in the [children] will be interleaved with [Padding] that has horizontal or
/// vertical spacing of [childrenPadding], depending on the value of [direction], which determines the arrangement
/// of the [children].
///
/// This widget can be used as a direct replacement for a [Flex] widget so that padding can be applied to every
/// element in the padding with the [childrenPadding] parameter rather than having to wrap each child in a
/// [Padding] widget.
class PaddedFlex extends StatelessWidget {
  /// Creates an instance of [PaddedFlex].
  const PaddedFlex({
    required this.direction,
    required this.childrenPadding,
    required this.children,
    super.key,
    this.mainAxisAlignment,
  });

  /// Determines how the [children] are arranged.
  final Axis direction;

  /// The padding to apply between children.
  final double childrenPadding;

  /// A list of widgets to display in the [Row].
  final List<Widget> children;

  /// Determines the way tha the [children] are arranged in the [Row].
  final MainAxisAlignment? mainAxisAlignment;

  /// Returns a [List<Widget>] in which each widget in the
  List<Widget> _getPaddedChildren() {
    final List<Widget> paddedWidgets = [];

    final Padding padding = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: direction == Axis.horizontal ? childrenPadding : 0,
        vertical: direction == Axis.vertical ? childrenPadding : 0,
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
    return Flex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
      children: _getPaddedChildren(),
    );
  }
}
