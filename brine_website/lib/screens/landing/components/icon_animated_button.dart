import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/primary_cta_button.dart';

/// A CTA button with an icon on either side.
class IconAnimatedButton extends StatelessWidget {
  const IconAnimatedButton({
    super.key,
    required this.iconSpacing,
    required this.startAnimationCallback,
    required this.stopAnimationCallback,
    required this.onTap,
  });

  /// The padding between the central button and the icons on either side.
  final double iconSpacing;

  /// A callback to start the animation when the cursor hovers over the CTA button.
  final Function(PointerEnterEvent) startAnimationCallback;

  /// A callback to stop the animation when the cursor exits the CTA button.
  final Function(PointerExitEvent) stopAnimationCallback;

  /// The action performed when the CTA button is tapped.
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FaIcon(
          FontAwesomeIcons.handPointRight,
          size: 42,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: iconSpacing,
          ),
          child: MouseRegion(
            onEnter: startAnimationCallback,
            onExit: stopAnimationCallback,
            child: PrimaryCTAButton(
              onTap: onTap,
              text: AppLocalizations.of(context).getStartedButton,
            ),
          ),
        ),
        const FaIcon(
          FontAwesomeIcons.handPointLeft,
          size: 42,
        ),
      ],
    );
  }
}
