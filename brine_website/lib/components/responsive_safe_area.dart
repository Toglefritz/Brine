import 'package:flutter/material.dart';

/// A widget that ensures that every page in a Flutter web app is scrollable, avoids overflows in width or height,
/// and prevents "hasSize" exceptions.
///
/// This widget uses a [SingleChildScrollView], [ConstrainedBox], and [IntrinsicHeight] to make sure that the
/// content of the body of a Scaffold is scrollable and doesn't cause overflow issues.
///
/// Example usage:
/// ```dart
/// ResponsiveSafeArea(
///   child: Column(
///     children: <Widget>[
///       // Your widgets here.
///     ],
///   ),
/// )
/// ```
class ResponsiveSafeArea extends StatelessWidget {
  /// The widget that is below this widget in the tree.
  final Widget child;

  /// Creates a [ResponsiveSafeArea] with the given [child].
  const ResponsiveSafeArea({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
