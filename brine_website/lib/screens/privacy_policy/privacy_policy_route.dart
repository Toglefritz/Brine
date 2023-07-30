import 'package:flutter/material.dart';

import 'privacy_policy_controller.dart';

/// Displays the Splendid Endeavors terms and conditions.
class PrivacyPolicyRoute extends StatefulWidget {
  static String get screenName => '/privacy';

  const PrivacyPolicyRoute({super.key});

  @override
  State<PrivacyPolicyRoute> createState() => PrivacyPolicyController();
}
