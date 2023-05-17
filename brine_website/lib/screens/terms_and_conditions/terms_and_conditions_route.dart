import 'package:flutter/material.dart';

import '../../../components/navigable_page.dart';
import 'terms_and_conditions_controller.dart';

/// Displays the Splendid Endeavors terms and conditions.
class TermsAndConditionsRoute extends NavigablePage {
  @override
  String get screenName => '/terms';

  const TermsAndConditionsRoute({super.key});

  @override
  State<TermsAndConditionsRoute> createState() => TermsAndConditionsController();
}
