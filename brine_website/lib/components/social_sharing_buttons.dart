import 'package:brinemonitor/components/padded_row.dart';
import 'package:brinemonitor/models/social_network.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../services/analytics/analytics.dart';
import '../values/assets.dart';
import '../values/insets.dart';

/// Displays a list of buttons to share Brine on various social networks.
class SocialSharingButtons extends StatelessWidget {
  const SocialSharingButtons({
    super.key,
    this.successCallback,
  });

  /// A method called after the share operation is completed successfully.
  final Function()? successCallback;

  /// Allows the visitor to share a link and message about Brine on various different [SocialNetwork]s.
  Future<void> _socialShare(SocialNetwork network) async {
    switch (network) {
      case SocialNetwork.threads:
        // TODO: Handle this case.
        break;
      case SocialNetwork.formerlyTwitter:
        Analytics.logEvent(
          name: 'twitter_share',
        );

        await _launchUrl(
          Uri.parse(
            'https://twitter.com/intent/tweet?text=🧂 Is your water softener low on salt? 🧂&url=http://brinemonitor.com/',
          ),
        );
        break;
      case SocialNetwork.facebook:
        Analytics.logEvent(
          name: 'facebook_share',
        );

        await _launchUrl(
          Uri.parse(
            'https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Fbrinemonitor.com%2F&amp;src=sdkpreparse',
          ),
        );
        break;
      case SocialNetwork.linkedin:
        Analytics.logEvent(
          name: 'linkedin_share',
        );

        await _launchUrl(
          Uri.parse(
            'https://www.linkedin.com/shareArticle?mini=true&url=http://brinemonitor.com/&title=🧂 Is your water softener low on salt? 🧂',
          ),
        );
        break;
      case SocialNetwork.pinterest:
        Analytics.logEvent(
          name: 'pinterest_share',
        );

        await _launchUrl(
          Uri.parse(
            'http://pinterest.com/pin/create/button/?url=http://brinemonitor.com/&description=🧂 Is your water softener low on salt? 🧂',
          ),
        );
        break;
      case SocialNetwork.share:
        Analytics.logEvent(
          name: 'generic_share',
        );

        Share.share(
          'I came across something truly fascinating that will, without a doubt, win a nobel prize in the near future. So, I used AI to write this email since I thought the project would be of great interest to you. It\'s called Brine (the "something" I was referring to in the previous sentence), and it\'s an incredible IoT water softener monitor that\'s about to launch on Kickstarter. I couldn\'t resist sharing it with you because I know how important home maintenance is to you. \n\n https://brinemonitor.com',
          subject: 'Something truly wonderful (and a little salty)',
        );
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
    return PaddedRow(
      childrenPadding: Insets.small,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Image.asset(
            Asset.wasTwitter.path,
            width: 36,
          ),
          color: Theme.of(context).primaryColorDark,
          onPressed: () => _socialShare(SocialNetwork.formerlyTwitter),
        ),
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.facebook,
            size: 36,
          ),
          color: Theme.of(context).primaryColorDark,
          onPressed: () => _socialShare(SocialNetwork.facebook),
        ),
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.linkedin,
            size: 36,
          ),
          color: Theme.of(context).primaryColorDark,
          onPressed: () => _socialShare(SocialNetwork.linkedin),
        ),
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.pinterest,
            size: 36,
          ),
          color: Theme.of(context).primaryColorDark,
          onPressed: () => _socialShare(SocialNetwork.pinterest),
        ),
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.squareShareNodes,
            size: 36,
          ),
          color: Theme.of(context).primaryColorDark,
          onPressed: () => _socialShare(SocialNetwork.share),
        ),
      ],
    );
  }
}
