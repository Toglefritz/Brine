/// Displays information about an error that occurred in the app.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/app_bar/main_app_bar.dart';
import '../../components/buttons/light_button.dart';
import '../../extensions/brightness_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics/analytics.dart';
import '../../services/authentication/authentication_service.dart';
import '../../theme/insets.dart';
import '../authentication/onboarding/onboarding_route.dart';
import '../device_configuration/scan/scan_route.dart';
import 'models/error_action.dart';
import 'models/error_type.dart';

part 'error_controller.dart';
part 'error_view.dart';

/// Displays information about an error that occurred in the app.
///
/// This route is displayed when an error occurs in the app. It provides information about the error and allows the user
/// to attempt to recover from the error.
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
