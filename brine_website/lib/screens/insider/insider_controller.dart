import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../components/navigable_page_controller.dart';
import '../../themes/screen_info.dart';
import 'insider_route.dart';
import 'insider_view_desktop.dart';
import 'insider_view_handheld.dart';

/// Controller for the [InsiderRoute].
class InsiderController extends NavigablePageController<InsiderRoute> {
  @override
  void initState() {
    if (kDebugMode == false) {
      FirebaseAnalytics.instance.logScreenView(screenName: 'insider_page_opened');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (ScreenInfo.width(context) > 900) {
          return InsiderViewDesktop(this);
        } else {
          return InsiderViewHandheld(this);
        }
      },
    );
  }
}
