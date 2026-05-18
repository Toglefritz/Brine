import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../authentication/models/auth_methods.dart';

/// Provides methods for tracking user interactions, app usage, errors, metadata, and other information for analytics.
///
/// The methods within this class only send analytics information to the analytics provider if the app is running in
/// release mode. In debug mode, the firing of analytics calls is indicated by print statements but the calls themselves
/// are not sent.
class Analytics {
  /// Tracks a page view event.
  static void trackPageView(String pageName) {
    debugPrint('Analytics trackPageView: $pageName');

    // coverage:ignore-start
    if (!kDebugMode) {
      unawaited(
        FirebaseAnalytics.instance.logScreenView(
          screenName: pageName,
        ),
      );
    }
    // coverage:ignore-end
  }

  /// Tracks a sign-up event.
  static void trackSignUp(AuthMethod signUpMethod) {
    debugPrint('Analytics trackSignUp');

    // coverage:ignore-start
    if (!kDebugMode) {
      unawaited(FirebaseAnalytics.instance.logSignUp(signUpMethod: signUpMethod.name));
    }
    // coverage:ignore-end
  }

  /// Tracks login events.
  static void trackLogin() {
    debugPrint('Analytics trackLogin');

    // coverage:ignore-start
    if (!kDebugMode) {
      unawaited(FirebaseAnalytics.instance.logLogin());
    }
    // coverage:ignore-end
  }

  /// Tracks logout events.
  static void trackLogout() {
    debugPrint('Analytics trackLogout');

    // coverage:ignore-start
    if (!kDebugMode) {
      unawaited(FirebaseAnalytics.instance.logEvent(name: 'logout'));
    }
    // coverage:ignore-end
  }

  /// Tracks a custom event with an optional map of parameters.
  static void trackEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) {
    debugPrint('Analytics trackEvent: $eventName, $parameters');

    // coverage:ignore-start
    if (!kDebugMode) {
      unawaited(
        FirebaseAnalytics.instance.logEvent(
          name: eventName,
          parameters: parameters,
        ),
      );
    }
    // coverage:ignore-end
  }
}
