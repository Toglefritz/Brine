import 'package:brinemonitor/screens/landing/landing_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../insider/insider_route.dart';
import 'setup_route.dart';
import 'setup_view.dart';

/// Controller for the [ThanksRoute].
///
/// This screen displays for visitors who have signed up to receive updates from Brine, either because they have just
/// completed the signup form presented by [EmailOptinAnimatedDialog] or because, after completing that form and having
/// a flag set via [SharedPreferences] the visitor returns to the site.
///
/// This screen features a big ol' party with a bunch of confetti that displays when the page launches and a very
/// special GIF thanking the visitor for their interest in Brine. The page shows updates about Brine and links
/// to share the project with others.
class SetupController extends State<SetupRoute> {
  @override
  void initState() {
    if (kDebugMode == false) {
      FirebaseAnalytics.instance.logAppOpen();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
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
