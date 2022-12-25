import 'package:flutter/material.dart';

import 'create_account_controller.dart';

/// Provides options for users to either create a new account or authenticate with an existing account.
class CreateAccountRoute extends StatefulWidget {
  const CreateAccountRoute({super.key});

  @override
  State<CreateAccountRoute> createState() => CreateAccountController();
}
