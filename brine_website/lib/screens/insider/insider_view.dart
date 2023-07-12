import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/app_bar/main_app_bar.dart';
import '../../values/insets.dart';
import '../../components/footer.dart';
import 'components/timeline/timelines_tab_bar.dart';
import 'components/timeline/timelines_tab_view.dart';
import 'insider_controller.dart';

/// View for the [OnboardingRoute].
class InsiderView extends StatelessWidget {
  final InsiderController state;

  const InsiderView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: const MainAppBar(),
        body: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Insets.kInsetsLarge,
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Insets.kInsetsMedium,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1200,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: Insets.kInsetsSmall,
                        ),
                        child: Text(
                          AppLocalizations.of(context).insiderPageTitle,
                          style: GoogleFonts.changaOne().copyWith(
                            fontSize: 42,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (FirebaseAuth.instance.currentUser?.displayName != null)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: Insets.kInsetsLarge,
                          ),
                          child: Text(
                            '${AppLocalizations.of(context).insiderPageSubtitle}${FirebaseAuth.instance.currentUser?.displayName}.',
                            style: GoogleFonts.changaOne().copyWith(
                              fontSize: 28,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: Insets.kInsetsMedium,
                          left: Insets.kInsetsSmall,
                        ),
                        child: Text(
                          AppLocalizations.of(context).projectTimelines,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const TimelinesTabBar(),
                      const TimelinesTabView(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Insets.kInsetsLarge,
                        ),
                        child: const Footer(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
