import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../../../components/navigable_page_controller.dart';
import 'privacy_policy_route.dart';
import 'privacy_policy_view.dart';

/// Controller for the [HomeRoute].
class PrivacyPolicyController extends NavigablePageController<PrivacyPolicyRoute> {
  @override
  void initState() {
    FirebaseAnalytics.instance.logEvent(name: 'privacy_policy_page_opened');
    super.initState();
  }

  /// Handles taps on the [AppBar] back button.
  void onBackPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => PrivacyPolicyView(this);
}
