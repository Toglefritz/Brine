import 'package:flutter/material.dart';

import '../../services/device_management/models/brine_device.dart';
import 'account_controller.dart';

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
