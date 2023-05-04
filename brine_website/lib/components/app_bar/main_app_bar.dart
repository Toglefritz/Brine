import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../screens/landing/landing_route.dart';
import '../../values/assets.dart';
import '../../values/insets.dart';

/// The main [AppBar] appearing at the top of the website for most pages.
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    this.displayBackButton,
    this.bottom,
    super.key,
  });

  /// Determines if a back button should be displayed in the [AppBar]
  final bool? displayBackButton;

  /// A widget to display at the bottom of the [AppBar].
  final PreferredSizeWidget? bottom;

  /// The height of the [AppBar].
  double get _height => bottom == null ? 72.0 : 144.0;

  @override
  Size get preferredSize => Size.fromHeight(_height);

  /// Handles taps on the back navigation button
  void goBack(BuildContext context) {
    context.go(const LandingRoute().screenName);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _height,
      leading: Padding(
        padding: const EdgeInsets.only(top: insetsMedium, left: insetsLarge),
        child: Row(
          children: [
            if (displayBackButton == true)
              Padding(
                padding: const EdgeInsets.only(right: insetsMedium),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => goBack(context),
                    child: const FaIcon(
                      FontAwesomeIcons.leftLong,
                      size: 42,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: insetsSmall),
              child: Image.asset(
                Assets.brineLogo.path,
                width: 56,
              ),
            ),
            Text(
              AppLocalizations.of(context).brine,
              style: GoogleFonts.changaOne().copyWith(
                fontSize: 32,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          ],
        ),
      ),
      leadingWidth: 300,
      bottom: bottom,
    );
  }
}
