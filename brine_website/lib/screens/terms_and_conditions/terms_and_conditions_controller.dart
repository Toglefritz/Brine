import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'terms_and_conditions_route.dart';
import 'terms_and_conditions_view.dart';

/// Controller for the [TermsAndConditionsRoute].
class TermsAndConditionsController extends State<TermsAndConditionsRoute> {
  @override
  void initState() {
    if (!kDebugMode) {
      unawaited(FirebaseAnalytics.instance.logScreenView(screenName: 'terms_and_conditions'));
    }

    super.initState();
  }

  /// Handles taps on the [AppBar] back button.
  void onBackPressed() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) => TermsAndConditionsView(this);
}
