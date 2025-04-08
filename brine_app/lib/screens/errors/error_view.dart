import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../extensions/brightness_extensions.dart';
import '../../values/image_asset.dart';
import 'error_controller.dart';
import 'error_route.dart';

/// View for the [ErrorRoute].
class ErrorView extends StatelessWidget {
  /// Creates an instance of [ErrorView].
  const ErrorView(this.state, {super.key});

  /// A controller for this view.
  final ErrorController state;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      Theme.of(context).brightness.oppositeSystemOverlayStyle(),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              ImageAsset.error.path,
              width: 256,
              height: 256,
            ),
          ],
        ),
      ),
    );
  }
}
