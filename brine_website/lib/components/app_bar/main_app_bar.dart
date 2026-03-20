import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../screens/landing/landing_route.dart';
import '../../services/analytics/analytics.dart';
import '../../themes/dark_theme_provider.dart';
import '../../values/assets.dart';
import '../../values/insets.dart';
import 'dark_theme_toggle.dart';

/// The main [AppBar] appearing at the top of the website for most pages.
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an instance of [MainAppBar].
  const MainAppBar({
    this.displayBackButton,
    this.bottom,
    this.confettiCallback,
    super.key,
  });

  /// Determines if a back button should be displayed in the [AppBar]
  final bool? displayBackButton;

  /// A widget to display at the bottom of the [AppBar].
  final PreferredSizeWidget? bottom;

  /// The height of the [AppBar].
  double get _height => bottom == null ? 72.0 : 144.0;

  /// A callback triggered when the confetti button is pressed. If null, the confetti button is not
  /// shown in the [AppBar].
  final VoidCallback? confettiCallback;

  @override
  Size get preferredSize => Size.fromHeight(_height);

  /// Handles taps on the back navigation button
  void _goBack(BuildContext context) {
    context.go(const LandingRoute().screenName);
  }

  /// Handles taps on the dark theme toggle by setting the dark theme preference to the value of the toggle.
  void _toggleDarkTheme({required bool isActive, required BuildContext context}) {
    Analytics.logEvent(
      name: 'dark_mode_toggle',
      parameters: {
        'enabled': isActive.toString(),
      },
    );

    Provider.of<DarkThemeProvider>(context, listen: false).darkTheme = isActive;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _height,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.only(
          top: Insets.medium,
          left: Insets.large,
        ),
        child: Row(
          children: [
            if (displayBackButton ?? false)
              Padding(
                padding: EdgeInsets.only(
                  right: Insets.medium,
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _goBack(context),
                    child: const FaIcon(
                      FontAwesomeIcons.leftLong,
                      size: 42,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                right: Insets.small,
              ),
              child: Image.asset(
                Asset.brineLogo.path,
                width: 56,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.brine.toUpperCase(),
              style: GoogleFonts.bungee().copyWith(
                fontSize: 32,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          ],
        ),
      ),
      leadingWidth: 300,
      actions: [
        if (confettiCallback != null)
          Padding(
            padding: EdgeInsets.only(
              right: Insets.medium,
            ),
            child: IconButton(
              icon: Icon(
                Icons.celebration,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: confettiCallback,
            ),
          ),
        Padding(
          padding: EdgeInsets.only(
            right: Insets.medium,
          ),
          child: DarkThemeToggle(
            onChanged: _toggleDarkTheme,
          ),
        ),
      ],
      bottom: bottom,
    );
  }
}
