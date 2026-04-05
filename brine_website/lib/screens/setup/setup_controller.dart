import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../insider/insider_route.dart';
import '../landing/landing_route.dart';
import 'setup_route.dart';
import 'setup_view.dart';

/// Controller for the [SetupRoute].
class SetupController extends State<SetupRoute> {
  @override
  void initState() {
    if (!kDebugMode) {
      FirebaseAnalytics.instance.logAppOpen();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          // Check if the user is logged in
          if (snapshot.hasData) {
            return const InsiderRoute();
          } else {
            return const LandingRoute();
          }
        }
        // Display a loading indicator until the auth state can be ascertained
        else {
          return const SetupView();
        }
      },
    );
  }
}
