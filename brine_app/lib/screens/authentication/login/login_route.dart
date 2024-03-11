import 'package:flutter/material.dart';

import 'login_controller.dart';

/// Provides options for users to either create a new account or authenticate with an existing account.
class LoginRoute extends StatefulWidget {
  /// Create an instance of [LoginRoute].
  const LoginRoute({super.key});

  @override
  State<LoginRoute> createState() => LoginController();
}
