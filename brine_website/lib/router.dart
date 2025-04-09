import 'dart:core';

import 'package:flutter/material.dart';
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
      builder: (BuildContext context, GoRouterState state) => const SetupRoute(),
    ),
    GoRoute(
      path: const LandingRoute().screenName,
      builder: (BuildContext context, GoRouterState state) => const LandingRoute(),
    ),
    GoRoute(
      path: PrivacyPolicyRoute.screenName,
      builder: (BuildContext context, GoRouterState state) => const PrivacyPolicyRoute(),
    ),
    GoRoute(
      path: TermsAndConditionsRoute.screenName,
      builder: (BuildContext context, GoRouterState state) => const TermsAndConditionsRoute(),
    ),
    GoRoute(
      path: '${ThanksRoute.screenName}/:name',
      builder: (BuildContext context, GoRouterState state) {
        final String name = state.pathParameters['name']!;

        return ThanksRoute(
          name: name,
        );
      },
    ),
    GoRoute(
      path: InsiderRoute.screenName,
      builder: (BuildContext context, GoRouterState state) => const InsiderRoute(),
    ),
  ],
);
