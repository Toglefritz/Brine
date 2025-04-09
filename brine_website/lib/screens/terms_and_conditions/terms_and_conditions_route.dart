import 'package:flutter/material.dart';

import 'terms_and_conditions_controller.dart';

/// Displays the Splendid Endeavors terms and conditions.
class TermsAndConditionsRoute extends StatefulWidget {
  /// The route name for the terms and conditions page.
  static String get screenName => '/terms';

  /// The route name for the privacy policy page.
  const TermsAndConditionsRoute({super.key});

  @override
  State<TermsAndConditionsRoute> createState() => TermsAndConditionsController();
}
