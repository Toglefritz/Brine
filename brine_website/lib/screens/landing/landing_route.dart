import 'package:flutter/cupertino.dart';

import 'landing_controller.dart';

/// A landing page used to explain and sell the features of **Brine** to visitors and includes calls to action
/// that drive visitors to sign up for updates. Also includes supplementary resources such as press kits,
/// resources, legal information, and other assets.
class LandingRoute extends StatefulWidget {
  String get screenName => '/hello';

  const LandingRoute({super.key});

  @override
  LandingController createState() => LandingController();
}
