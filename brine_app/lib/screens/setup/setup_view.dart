import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../softener_monitor/softener_monitor_route.dart';
import 'setup_controller.dart';

/// View for [SoftenerMonitorRoute].
class SetupView extends StatelessWidget {
  /// Creates an instance of [SetupView].
  const SetupView(this.state, {super.key});

  /// A controller for this view.
  final SetupController state;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitWave(
              color: Theme.of(context).primaryColorDark,
            ),
          ],
        ),
      ),
    );
  }
}
