import 'package:flutter/cupertino.dart';

import 'insider_controller.dart';

/// A special page thanking the visitor for signing up for updates from Brine. This page is only shown after the user
/// submits the form used to enroll for updates. It features a very cute little frog saying, "thanks."
class InsiderRoute extends StatefulWidget {
  /// The route name for the InsiderRoute.
  static String get screenName => '/insider';

  /// Creates an instance of [InsiderRoute].
  const InsiderRoute({
    super.key,
  });

  @override
  InsiderController createState() => InsiderController();
}
