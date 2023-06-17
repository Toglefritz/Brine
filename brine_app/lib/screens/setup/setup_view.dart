import 'package:brine/screens/setup/setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../theme/color_library.dart';

/// View for [SoftenerMonitorRoute].
class SetupView extends StatelessWidget {
  final SetupController state;

  const SetupView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            SpinKitWave(
              color: ColorLibrary.primaryDefault,
            ),
          ],
        ),
      ),
    );
  }
}
