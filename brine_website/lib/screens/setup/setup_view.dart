import 'package:flutter/material.dart';

import 'setup_route.dart';

/// View for the [SetupRoute].
class SetupView extends StatelessWidget {
  /// Constructor for the [SetupView].
  const SetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
