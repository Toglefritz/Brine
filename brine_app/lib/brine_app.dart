import 'package:brine/screens/setup/setup_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:brine/screens/authentication/onboarding/onboarding_route.dart';
import 'package:brine/theme/build_theme_data.dart';

/// The entry point of the application.
///
/// The [BrineApp] widget returns a [MaterialApp]
class BrineApp extends StatelessWidget {
  const BrineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brine',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.hasData) {
              return const SetupRoute();
            }
            return const OnboardingRoute();
          },
        ),
      ),
    );
  }
}
