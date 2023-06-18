import 'package:brine/theme/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../onboarding/components/onboarding_legal_prompt.dart';

/// A page presented as part of the authentication process.
class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({
    super.key,
    required this.backOnTap,
    required this.content,
  });

  /// The action to perform when the back button in the [AppBar] is pressed.
  final Function()? backOnTap;

  /// The main content of the page between the [AppBar] and the legal links
  /// at the bottom of the page.
  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: backOnTap,
          icon: const Icon(
            Icons.chevron_left,
            color: ColorLibrary.primaryDefault,
          ),
          label: Text(
            AppLocalizations.of(context).back.toUpperCase(),
            style: const TextStyle(
              color: ColorLibrary.primaryDefault,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: content
                  ..add(
                    const Expanded(
                      child: Column(
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
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
