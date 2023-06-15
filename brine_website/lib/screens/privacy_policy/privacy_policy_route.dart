import 'package:flutter/material.dart';

import '../../components/navigable_page.dart';
import 'privacy_policy_controller.dart';

/// Displays the Splendid Endeavors terms and conditions.
class PrivacyPolicyRoute extends NavigablePage {
  static String get screenName => '/privacy';

  const PrivacyPolicyRoute({super.key});

  @override
  State<PrivacyPolicyRoute> createState() => PrivacyPolicyController();
}
