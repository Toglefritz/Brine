import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/app_bar/main_app_bar.dart';
import '../../values/insets.dart';
import '../../components/footer.dart';
import 'insider_controller.dart';

/// View for the [OnboardingRoute].
class InsiderView extends StatelessWidget {
  final InsiderController state;

  const InsiderView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: insetsLarge),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: insetsMedium),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 900,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: insetsLarge,
                      ),
                      child: Text(
                        AppLocalizations.of(context).insiderPageTitle,
                        style: GoogleFonts.changaOne().copyWith(
                          fontSize: 42,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: insetsLarge),
                      child: Footer(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
