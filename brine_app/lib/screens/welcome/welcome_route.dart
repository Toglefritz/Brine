import 'package:brine/screens/welcome/welcome_controller.dart';
import 'package:flutter/material.dart';

/// Displays a page for an authenticated user without any devices associated to their account. The page invites the
/// user to add a device to their account.
class WelcomeRoute extends StatefulWidget {
  const WelcomeRoute({super.key});

  @override
  State<WelcomeRoute> createState() => WelcomeController();
}
