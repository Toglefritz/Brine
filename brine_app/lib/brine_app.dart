import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/authentication/onboarding/onboarding_route.dart';
import 'screens/setup/setup_route.dart';
import 'theme/brine_app_theme.dart';

/// The entry point of the application.
///
/// Listens to the authentication state and routes to either the [SetupRoute] (authenticated) or the [OnboardingRoute]
/// (unauthenticated). The auth state stream can be injected for testing.
class BrineApp extends StatelessWidget {
  /// Creates an instance of [BrineApp].
  const BrineApp({
    this.authStateStream,
    super.key,
  });

  /// An optional stream of authentication state changes.
  ///
  /// When null, the app uses `FirebaseAuth.instance.authStateChanges()`. Providing a stream in tests allows
  /// verification of the routing logic without Firebase platform initialization.
  final Stream<User?>? authStateStream;

  /// A key used for the [Navigator] provided by the [MaterialApp] widget.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brine',
      debugShowCheckedModeBanner: false,
      theme: BrineAppTheme.lightThemeData,
      darkTheme: BrineAppTheme.darkThemeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorKey: navigatorKey,
      home: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: StreamBuilder<User?>(
          stream: authStateStream ?? FirebaseAuth.instance.authStateChanges(),
          builder: (context, authStateSnapshot) {
            if (authStateSnapshot.hasData) {
              return const SetupRoute();
            }
            return const OnboardingRoute();
          },
        ),
      ),
    );
  }
}
