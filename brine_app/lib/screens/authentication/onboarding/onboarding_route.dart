import 'package:flutter/material.dart';

import 'onboarding_controller.dart';

/// Provides options for users to either create a new account or authenticate with an existing account.
class OnboardingRoute extends StatefulWidget {
  const OnboardingRoute({super.key});

  @override
  State<OnboardingRoute> createState() => OnboardingController();
}
