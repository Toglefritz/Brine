import 'dart:core';

import 'package:go_router/go_router.dart';

import 'screens/insider/insider_route.dart';
import 'screens/landing/landing_route.dart';
import 'screens/privacy_policy/privacy_policy_route.dart';
import 'screens/setup/setup_route.dart';
import 'screens/terms_and_conditions/terms_and_conditions_route.dart';
import 'screens/thanks/thanks_route.dart';

/// GoRouter configuration.
///
/// This global variable defines routes used with the *go_router* package.
GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: const SetupRoute().screenName,
      builder: (context, state) => const SetupRoute(),
    ),
    GoRoute(
      path: const LandingRoute().screenName,
      builder: (context, state) => const LandingRoute(),
    ),
    GoRoute(
      path: PrivacyPolicyRoute.screenName,
      builder: (context, state) => const PrivacyPolicyRoute(),
    ),
    GoRoute(
      path: TermsAndConditionsRoute.screenName,
      builder: (context, state) => const TermsAndConditionsRoute(),
    ),
    GoRoute(
      path: '${ThanksRoute.screenName}/:name',
      builder: (context, state) {
        final String name = state.pathParameters['name']!;

        return ThanksRoute(
          name: name,
        );
      },
    ),
    GoRoute(
      path: InsiderRoute.screenName,
      builder: (context, state) => const InsiderRoute(),
    ),
  ],
);
