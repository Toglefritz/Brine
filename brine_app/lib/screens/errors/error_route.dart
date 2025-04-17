import 'package:flutter/material.dart';

import 'error_controller.dart';
import 'models/error_type.dart';

/// Displays information about an error that occurred in the app.
///
/// This route is displayed when an error occurs in the app. It provides information about the error and allows the
/// user to attempt to recover from the error.
class ErrorRoute extends StatefulWidget {
  /// Creates an instance of [ErrorRoute].
  const ErrorRoute({
    required this.errorType,
    super.key,
  });

  /// An identifier for the type of error that occurred.
  ///
  /// This identifier is used to determine the type of error that occurred and how to handle it. This route determines
  /// the troubleshooting steps or other information or actions based on the error type.
  final ErrorType errorType;

  @override
  State<ErrorRoute> createState() => ErrorController();
}
