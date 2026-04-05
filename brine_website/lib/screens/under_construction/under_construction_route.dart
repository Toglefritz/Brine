import 'package:flutter/cupertino.dart';

import 'under_construction_controller.dart';

/// Entry point for the under construction page displayed while the website is being refreshed. Gated behind a
/// `--dart-define` flag so it can be toggled at build time without touching the router.
class UnderConstructionRoute extends StatefulWidget {
  /// The route path for this screen.
  static const String screenName = '/under-construction';

  /// Creates an instance of [UnderConstructionRoute].
  const UnderConstructionRoute({super.key});

  @override
  UnderConstructionController createState() => UnderConstructionController();
}
