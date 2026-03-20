import 'package:flutter/cupertino.dart';

import 'thanks_controller.dart';

/// A special page thanking the visitor for signing up for updates from Brine. This page is only shown after the user
/// submits the form used to enroll for updates. It features a very cute little frog saying, "thanks."
class ThanksRoute extends StatefulWidget {
  /// The route name for the ThanksRoute.
  static String get screenName => '/thanks';

  /// The first name of the visitor, as supplied in the email optin form.
  final String name;

  /// Creates an instance of [ThanksRoute].
  const ThanksRoute({
    required this.name,
    super.key,
  });

  @override
  ThanksController createState() => ThanksController();
}
