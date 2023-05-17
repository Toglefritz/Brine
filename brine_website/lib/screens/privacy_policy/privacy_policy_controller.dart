import 'package:flutter/material.dart';

import '../../../components/navigable_page_controller.dart';
import 'privacy_policy_route.dart';
import 'privacy_policy_view.dart';

/// Controller for the [HomeRoute].
class PrivacyPolicyController extends NavigablePageController<PrivacyPolicyRoute> {
  /// Handles taps on the [AppBar] back button.
  void onBackPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => PrivacyPolicyView(this);
}
