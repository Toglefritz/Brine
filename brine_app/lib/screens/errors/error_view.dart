import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/app_bar/main_app_bar.dart';
import '../../components/buttons/light_button.dart';
import '../../extensions/brightness_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/insets.dart';
import '../../values/image_asset.dart';
import 'error_controller.dart';
import 'error_route.dart';
import 'models/error_type.dart';

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
      appBar: MainAppBar(
        // On this screen, there are, by definition, no devices to display.
        devices: const [],
        backgroundColor: Theme.of(context).primaryColor,
        menuIconColor: Theme.of(context).primaryColorLight,
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              ImageAsset.error.path,
              width: 256,
              height: 256,
            ),

            // If an authentication error occurred, display a message requesting that the user log in again.
            if (state.widget.errorType == ErrorType.unauthenticated) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Insets.medium,
                ),
                child: Text(
                  AppLocalizations.of(context)!.unauthenticatedError,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).primaryColorLight,
                      ),
                ),
              ),
              LightButton(
                text: AppLocalizations.of(context)!.login,
                onPressed: state.onLoginAgain,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
