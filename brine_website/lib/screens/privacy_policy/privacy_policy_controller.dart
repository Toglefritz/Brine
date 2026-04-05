import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'privacy_policy_route.dart';
import 'privacy_policy_view.dart';

/// Controller for the [PrivacyPolicyRoute].
class PrivacyPolicyController extends State<PrivacyPolicyRoute> {
  @override
  void initState() {
    if (!kDebugMode) {
      unawaited(FirebaseAnalytics.instance.logScreenView(screenName: 'privacy_policy'));
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
