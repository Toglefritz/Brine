/// This route displays information about the user's account including their devices and account settings.
library;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../components/buttons/light_button.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics/analytics.dart';
import '../../services/authentication/authentication_service.dart';
import '../../services/device_management/device_management_service.dart';
import '../../services/device_management/models/brine_device.dart';
import '../../theme/insets.dart';
import '../authentication/onboarding/onboarding_route.dart';
import '../welcome/welcome_route.dart';

part 'components/user_avatar.dart';
part 'account_controller.dart';
part 'account_view.dart';
part 'edit_profile_view.dart';
part 'components/device_list.dart';
part 'components/expandable_device_card.dart';

/// This route displays information about the user's account including their devices and account settings.
class AccountRoute extends StatefulWidget {
  /// Creates an instance of [AccountRoute].
  const AccountRoute({
    required this.devices,
    super.key,
  });

  /// A list of Brine devices on the user's account. This list is displayed to the user on this route and, for each
  /// device, the user is able to access basic information such as the device's name, current salt and battery level,
  /// firmware version, and the timestamp for when the device last updated its status.
  final List<BrineDevice> devices;

  @override
  State<AccountRoute> createState() => AccountController();
}
