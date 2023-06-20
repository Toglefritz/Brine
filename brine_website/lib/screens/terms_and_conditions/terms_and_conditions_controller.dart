import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../components/navigable_page_controller.dart';
import 'terms_and_conditions_route.dart';
import 'terms_and_conditions_view.dart';

/// Controller for the [HomeRoute].
class TermsAndConditionsController extends NavigablePageController<TermsAndConditionsRoute> {
  @override
  void initState() {
    FirebaseAnalytics.instance.logEvent(name: 'terms_and_conditions_page_opened');
    super.initState();
  }

  /// Handles taps on the [AppBar] back button.
  void onBackPressed() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) => TermsAndConditionsView(this);
}
