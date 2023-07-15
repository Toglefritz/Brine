import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../components/navigable_page_controller.dart';
import 'privacy_policy_route.dart';
import 'privacy_policy_view.dart';

/// Controller for the [HomeRoute].
class PrivacyPolicyController extends NavigablePageController<PrivacyPolicyRoute> {
  @override
  void initState() {
    if (kDebugMode == false) {
      FirebaseAnalytics.instance.logScreenView(screenName: 'privacy_policy');
    }
    super.initState();
  }

  /// Handles taps on the [AppBar] back button.
  void onBackPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => PrivacyPolicyView(this);
}
