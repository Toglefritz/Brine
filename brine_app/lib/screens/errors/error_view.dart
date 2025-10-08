import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/app_bar/main_app_bar.dart';
import '../../components/buttons/light_button.dart';
import '../../extensions/brightness_extensions.dart';
import '../../theme/insets.dart';
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
            // Error title
            Text(
              state.widget.errorType.errorTitle(context),
              style: GoogleFonts.bungee().copyWith(
                fontSize: 52,
                color: Theme.of(context).primaryColorLight,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Insets.medium,
              ),
              child: Image.asset(
                state.widget.errorType.errorImage().path,
                width: 256,
                height: 256,
              ),
            ),

            // Display a message to the user based on the error type.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Insets.medium,
              ),
              child: Text(
                state.widget.errorType.errorMessage(context),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).primaryColorLight,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            // Show a button for error types that have an associated action.
            if (state.getErrorAction() != null)
              LightButton(
                text: state.getErrorAction()!.label,
                onPressed: state.getErrorAction()!.onPressed,
              ),
          ],
        ),
      ),
    );
  }
}
