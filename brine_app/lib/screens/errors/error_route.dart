import 'package:flutter/material.dart';

import 'error_controller.dart';

/// Displays information about an error that occurred in the app.
///
/// This route is displayed when an error occurs in the app. It provides information about the error and allows the
/// user to attempt to recover from the error.
class ErrorRoute extends StatefulWidget {
  /// Creates an instance of [ErrorRoute].
  const ErrorRoute({super.key});

  @override
  State<ErrorRoute> createState() => ErrorController();
}
