import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../brine_app.dart';
import '../../screens/account/account_route.dart';
import '../../services/analytics/analytics.dart';
import '../../services/device_management/models/brine_device.dart';

/// The app's main [AppBar] widget, which is generally used on pages after the user is authenticated.
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an instance of [MainAppBar].
  const MainAppBar({
    required this.devices,
    super.key,
  });

  /// A list of Brine devices on the user's account.
  final List<BrineDevice> devices;

  @override
  Size get preferredSize => const Size.fromHeight(50);

  /// Handles taps on the "account" button, which navigates to the account page.
  Future<void> _onAccountTap() async {
    Analytics.trackEvent(eventName: 'account_menu_tap');

    if (BrineApp.navigatorKey.currentContext != null) {
      await Navigator.push(
        BrineApp.navigatorKey.currentContext!,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => AccountRoute(
            devices: devices,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _onAccountTap(),
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).primaryColorDark,
          ),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: AppLocalizations.of(context)!.logout,
                child: ListTile(
                  leading: const Icon(Icons.person_outlined),
                  title: Text(AppLocalizations.of(context)!.logout),
                ),
              ),
            ];
          },
        ),
      ],
    );
  }
}
