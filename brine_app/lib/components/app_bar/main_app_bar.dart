import 'package:flutter/material.dart';

import '../../brine_app.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/account/account_route.dart';
import '../../services/analytics/analytics.dart';
import '../../services/device_management/models/brine_device.dart';

/// The app's main [AppBar] widget, which is generally used on pages after the user is authenticated.
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an instance of [MainAppBar].
  const MainAppBar({
    required this.devices,
    this.backgroundColor,
    this.menuIconColor,
    super.key,
  });

  /// A list of Brine devices on the user's account.
  final List<BrineDevice> devices;

  /// Overrides the background color of the app bar.
  final Color? backgroundColor;

  /// Overrides the color of the app bar's menu icon.
  final Color? menuIconColor;

  @override
  Size get preferredSize => const Size.fromHeight(50);

  /// Handles taps on the "account" button, which navigates to the account page.
  Future<void> _onAccountTap() async {
    Analytics.trackEvent(eventName: 'account_menu_tap');

    if (BrineApp.navigatorKey.currentContext != null) {
      await Navigator.push(
        BrineApp.navigatorKey.currentContext!,
        MaterialPageRoute<void>(
          builder: (context) => AccountRoute(
            devices: devices,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _onAccountTap(),
          icon: Icon(
            Icons.more_vert,
            color: menuIconColor ?? Theme.of(context).primaryColorDark,
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem<String>(
                value: AppLocalizations.of(context)!.account,
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.account),
                ),
              ),
            ];
          },
        ),
      ],
    );
  }
}
