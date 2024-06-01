import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../brine_app.dart';
import '../screens/authentication/onboarding/onboarding_route.dart';
import '../services/analytics/analytics.dart';
import '../services/authentication/authentication_service.dart';

/// The app's main [AppBar] widget, which is generally used on pages after the user is authenticated.
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an instance of [MainAppBar].
  const MainAppBar({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(50);

  /// Handles taps on the "logout" button.
  Future<void> _onLogout() async {
    Analytics.trackEvent(eventName: 'logout_tap');

    await AuthenticationService.signOut();

    if (BrineApp.navigatorKey.currentContext != null) {
      await Navigator.pushReplacement(
        BrineApp.navigatorKey.currentContext!,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const OnboardingRoute(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _onLogout(),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: AppLocalizations.of(context)!.logout,
                child: Text(
                  AppLocalizations.of(context)!.logout,
                  textAlign: TextAlign.center,
                ),
              ),
            ];
          },
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ],
    );
  }
}
