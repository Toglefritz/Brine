import 'package:brine/screens/softener_monitor/softener_monitor_route.dart';
import 'package:brine/services/firebase/models/brine_device.dart';
import 'package:brine/theme/themes.dart';
import 'package:flutter/material.dart';

import '../../../values/assets.dart';

/// Provides a preview of the Brine mobile app by running the app itself, which is included as a submodule, inside
/// an iPhone frame mockup.
///
/// So, this preview of the Brine app is not really a preview at all. It is actually the real app running within inside
/// an aesthetic frame. This fully takes advantage of the idea (which is wrong) that everything in Flutter is a widget.
class AppPreview extends StatelessWidget {
  const AppPreview({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Reference a view from the Brine mobile app
        Theme(
          data: lightThemeData.copyWith(
            scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SizedBox(
            width: 300,
            height: 615,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              child: SoftenerMonitorRoute(
                devices: [
                  BrineDevice(
                    deviceId: 'slick_demo_device',
                    saltLevel: 0.7,
                    batteryLevel: 0.6,
                    retrievalTimestamp: DateTime.now(),
                  )
                ],
              ),
            ),
          ),
        ),
        Image.asset(
          Assets.iphone13Mockup.path,
          width: 300,
        ),
      ],
    );
  }
}
