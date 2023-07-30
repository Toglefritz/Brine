import 'package:flutter/material.dart';

import 'terms_and_conditions_controller.dart';

/// Displays the Splendid Endeavors terms and conditions.
class TermsAndConditionsRoute extends StatefulWidget {
  static String get screenName => '/terms';

  const TermsAndConditionsRoute({super.key});

  @override
  State<TermsAndConditionsRoute> createState() => TermsAndConditionsController();
}
