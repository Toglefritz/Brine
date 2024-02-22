import 'package:flutter/material.dart';

/// A widget that ensures all screens in a Flutter application can be scrolled, mitigates overflows in any dimension,
/// and avoids "hasSize" exceptions.
///
/// This widget incorporates a [SingleChildScrollView] and [ConstrainedBox] to guarantee that the body content
/// of the [Scaffold] is scrollable and eliminates any potential overflow issues.
///
/// Example of usage:
/// ```dart
/// ScrollableScaffold(
///   body: Column(
///     children: <Widget>[
///       // Insert your widgets here.
///     ],
///   ),
/// )
/// ```
class ResponsiveSafeScaffold extends StatelessWidget {
  /// Creates a [ResponsiveSafeScaffold] with the supplied [body].
  const ResponsiveSafeScaffold({
    Key? key,
    required this.body,
    this.appBar,
  }) : super(key: key);

  /// The body widget that is contained within this widget.
  final Widget body;

  /// An [AppBar] to display at the top of the [Scaffold].
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: body,
              ),
            );
          },
        ),
      ),
    );
  }
}
