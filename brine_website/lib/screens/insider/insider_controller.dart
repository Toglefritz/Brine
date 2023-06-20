import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../components/navigable_page_controller.dart';
import 'insider_route.dart';
import 'insider_view.dart';

/// Controller for the [InsiderRoute].
class InsiderController extends NavigablePageController<InsiderRoute> {
  @override
  void initState() {
    if (kDebugMode == false) {
      FirebaseAnalytics.instance.logEvent(name: 'insider_page_opened');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) => InsiderView(this);
}
