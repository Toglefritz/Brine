import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../components/app_bar/main_app_bar.dart';
import '../../components/footer/footer.dart';
import '../../components/layout/padded_column.dart';
import '../../components/social_sharing_buttons.dart';
import '../../values/insets.dart';
import 'components/app_notification_preview.dart';
import 'insider_controller.dart';
import 'insider_route.dart';

/// View for the [InsiderRoute].
class InsiderViewHandheld extends StatelessWidget {
  /// A controller for this view.
  final InsiderController state;

  /// Creates an instance of [InsiderViewHandheld].
  const InsiderViewHandheld(
    this.state, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: const MainAppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(
              Insets.medium,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1000,
              ),
              child: PaddedColumn(
                childrenPadding: Insets.medium,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.insiderPageTitle,
                    style: GoogleFonts.changaOne().copyWith(
                      fontSize: 42,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (FirebaseAuth.instance.currentUser?.displayName != null)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: Insets.medium,
                      ),
                      child: Text(
                        '${AppLocalizations.of(context)!.insiderPageSubtitle}${FirebaseAuth.instance.currentUser?.displayName}.',
                        style: GoogleFonts.changaOne().copyWith(
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Text(
                    AppLocalizations.of(context)!.insiderPageIntro,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const AppNotificationPreview(
                    width: 300.0,
                  ),
                  Text(
                    AppLocalizations.of(context)!.socialSharePrompt,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SocialSharingButtons(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Insets.large,
                    ),
                    child: const Footer(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
