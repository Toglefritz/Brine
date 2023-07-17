import 'package:brinemonitor/components/padded_column.dart';
import 'package:brinemonitor/screens/insider/components/app_notification_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/app_bar/main_app_bar.dart';
import '../../components/social_sharing_buttons.dart';
import '../../values/insets.dart';
import '../../components/footer.dart';
import 'components/timeline/timelines_tab_bar.dart';
import 'components/timeline/timelines_tab_view.dart';
import 'insider_controller.dart';

/// View for the [OnboardingRoute].
class InsiderViewDesktop extends StatelessWidget {
  final InsiderController state;

  const InsiderViewDesktop(
    this.state, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: const MainAppBar(),
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1000,
              ),
              child: PaddedColumn(
                childrenPadding: Insets.medium,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: PaddedColumn(
                          childrenPadding: Insets.medium,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context).insiderPageTitle,
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
                                  '${AppLocalizations.of(context).insiderPageSubtitle}${FirebaseAuth.instance.currentUser?.displayName}.',
                                  style: GoogleFonts.changaOne().copyWith(
                                    fontSize: 28,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            Text(
                              AppLocalizations.of(context).insiderPageIntro,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              AppLocalizations.of(context).socialSharePrompt,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SocialSharingButtons(),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: AppNotificationPreview(
                          width: 300.0,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: Insets.large,
                    ),
                    child: Text(
                      AppLocalizations.of(context).projectTimelines,
                      style: GoogleFonts.changaOne().copyWith(
                        fontSize: 32,
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).projectTimelinesExplanation,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const TimelinesTabBar(),
                  const TimelinesTabView(),
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
