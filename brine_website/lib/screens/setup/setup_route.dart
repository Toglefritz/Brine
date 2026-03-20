import 'package:flutter/cupertino.dart';

import 'setup_controller.dart';

/// Before the visitor can be navigated to the place where they belong, we need to determine if they are a new visitor.
/// This screen simply displays a loading indicator while this determination is made.
class SetupRoute extends StatefulWidget {
  /// The route name for the setup page.
  String get screenName => '/';

  /// Creates an instance of [SetupRoute].
  const SetupRoute({
    super.key,
  });

  @override
  SetupController createState() => SetupController();
}
