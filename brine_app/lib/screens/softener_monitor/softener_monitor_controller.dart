import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'softener_monitor_route.dart';
import 'softener_monitor_view.dart';

/// Controller for [SoftenerMonitorRoute].
class SoftenerMonitorController extends State<SoftenerMonitorRoute> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set the status bar icons depending upon the theme brightness
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).scaffoldBackgroundColor,
          statusBarBrightness: Theme.of(context).brightness,
          statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => SoftenerMonitorView(this);
}
