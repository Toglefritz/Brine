import 'package:flutter/material.dart';

import 'privacy_policy_controller.dart';

/// Displays the Splendid Endeavors terms and conditions.
class PrivacyPolicyRoute extends StatefulWidget {
  /// The route name for the privacy policy page.
  static String get screenName => '/privacy';

  /// The route name for the privacy policy page.
  const PrivacyPolicyRoute({super.key});

  @override
  State<PrivacyPolicyRoute> createState() => PrivacyPolicyController();
}
