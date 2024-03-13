import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../theme/insets.dart';
import '../onboarding/components/onboarding_legal_prompt.dart';

/// A page presented as part of the authentication process.
class AuthenticationPage extends StatelessWidget {
  /// Creates an instance of [AuthenticationPage].
  const AuthenticationPage({
    required this.backOnTap,
    required this.content,
    super.key,
  });

  /// The action to perform when the back button in the [AppBar] is pressed.
  final VoidCallback backOnTap;

  /// The main content of the page between the [AppBar] and the legal links
  /// at the bottom of the page.
  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leadingWidth: 100,
              leading: TextButton.icon(
                onPressed: backOnTap,
                icon: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).primaryColorDark,
                ),
                label: Text(
                  AppLocalizations.of(context)!.back.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
            ),
            SliverList.list(
              children: [
                ...content,
                const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(
                        Insets.medium,
                      ),
                      child: OnboardingLegalPrompt(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
