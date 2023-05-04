import 'package:flutter/material.dart';

/// Classes extending [NavigablePage] are navigable pages within the app. Each page, therefore, specifies a URL to be
/// used in navigation calls with the *go_router* package.
abstract class NavigablePage extends StatefulWidget {
  /// A string identifier for the screen used in logging calls.
  abstract final String screenName;

  const NavigablePage({super.key});
}
