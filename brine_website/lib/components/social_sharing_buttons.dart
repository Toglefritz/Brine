import 'package:brinemonitor/models/social_network.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays a list of buttons to share Brine on various social networks.
class SocialSharingButtons extends StatelessWidget {
  const SocialSharingButtons({
    super.key,
    this.successCallback,
  });

  final Function()? successCallback;

  /// Allows the visitor to share a link and message about Brine on various different [SocialNetwork]s.
  // TODO add tags
  Future<void> socialShare(SocialNetwork network) async {
    switch (network) {
      case SocialNetwork.threads:
        // TODO: Handle this case.
        break;
      case SocialNetwork.twitter:
        await _launchUrl(
          Uri.parse(
            'https://twitter.com/intent/tweet?text=🧂 Is your water softener low on salt? 🧂&url=http://brinemonitor.com/',
          ),
        );
        break;
      case SocialNetwork.facebook:
        await _launchUrl(
          Uri.parse(
            'https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Fbrinemonitor.com%2F&amp;src=sdkpreparse',
          ),
        );
        break;
      case SocialNetwork.linkedin:
        await _launchUrl(
          Uri.parse(
            'https://www.linkedin.com/shareArticle?mini=true&url=http://brinemonitor.com/&title=🧂 Is your water softener low on salt? 🧂',
          ),
        );
        break;
      case SocialNetwork.pinterest:
        await _launchUrl(
          Uri.parse(
            'http://pinterest.com/pin/create/button/?url=http://brinemonitor.com/&description=🧂 Is your water softener low on salt? 🧂',
          ),
        );
        break;
      case SocialNetwork.email:
        // TODO: Handle this case.
        break;
    }
  }

  /// Launches the provided URL or, if there is a problem with that, throws an exception.
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.twitter,
            size: 36,
          ),
          color: Theme.of(context).primaryColorDark,
          onPressed: () => socialShare(SocialNetwork.twitter),
        ),
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.facebook,
            size: 36,
          ),
          color: Theme.of(context).primaryColorDark,
          onPressed: () => socialShare(SocialNetwork.facebook),
        ),
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.linkedin,
            size: 36,
          ),
          color: Theme.of(context).primaryColorDark,
          onPressed: () => socialShare(SocialNetwork.linkedin),
        ),
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.pinterest,
            size: 36,
          ),
          color: Theme.of(context).primaryColorDark,
          onPressed: () => socialShare(SocialNetwork.pinterest),
        ),
      ],
    );
  }
}
