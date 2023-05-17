import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../components/navigable_page_controller.dart';
import 'terms_and_conditions_route.dart';
import 'terms_and_conditions_view.dart';

/// Controller for the [HomeRoute].
class TermsAndConditionsController extends NavigablePageController<TermsAndConditionsRoute> {
  /// Handles taps on the [AppBar] back button.
  void onBackPressed() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) => TermsAndConditionsView(this);
}
