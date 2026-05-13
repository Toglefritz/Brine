/// Displays a page for an authenticated user without any devices associated to their account. The page invites the user
/// to add a device to their account.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/app_bar/main_app_bar.dart';
import '../../components/buttons/light_button.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics/analytics.dart';
import '../../theme/insets.dart';
import '../device_configuration/scan/scan_route.dart';
import 'components/add_device_button.dart';

part 'welcome_controller.dart';
part 'welcome_view.dart';

/// Displays a page for an authenticated user without any devices associated to their account. The page invites the user
/// to add a device to their account.
class WelcomeRoute extends StatefulWidget {
  /// Creates and instance of [WelcomeRoute].
  const WelcomeRoute({super.key});

  @override
  State<WelcomeRoute> createState() => WelcomeController();
}
