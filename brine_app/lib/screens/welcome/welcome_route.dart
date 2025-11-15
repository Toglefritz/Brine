import 'package:flutter/material.dart';

import 'welcome_controller.dart';

/// Displays a page for an authenticated user without any devices associated to their account. The page invites the user
/// to add a device to their account.
class WelcomeRoute extends StatefulWidget {
  /// Creates and instance of [WelcomeRoute].
  const WelcomeRoute({super.key});

  @override
  State<WelcomeRoute> createState() => WelcomeController();
}
