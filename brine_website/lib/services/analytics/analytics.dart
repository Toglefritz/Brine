import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Provides convenience methods for making calls to [FirebaseAnalytics] that will only send data if
/// the app is not running in debug mode. The methods within this class also provide syntastic sugar by
/// avoiding the need to call ```FirebaseAnalytics.instance``` repeatedly throughout the codebase.
class Analytics {
  /// A wrapper for a call to the [FirebaseAnalytics] [logEvent] method that only sends data to Firebase if the
  /// app is not running in debug mode.
  ///
  /// The [eventName] parameter defines the name of the event. The name should contain 1 to 40 alphanumeric characters
  /// or underscores. The name must start with an alphabetic character.
  ///
  /// The [parameters] parameter lists additional data to be sent with the event. Passing null indicates that the
  /// event has no parameters. Parameter names can be up to 40 characters long and must start with an alphabetic
  /// character and contain only alphanumeric characters and underscores. The values for items in the [parameters]
  /// can be of type String, long, or double.
  ///
  /// Exceptions thrown by the underlying call to ```FirebaseAnalytics.instance.logEvent``` are rethrown, including
  /// exceptions resulting from invalid formats for the [eventName] or [parameters].
  static Future<void> logEvent({required String name, Map<String, Object>? parameters}) async {
    try {
        await FirebaseAnalytics.instance.logEvent(
          name: name,
          parameters: parameters,
        );
    } catch (e) {
      debugPrint('logEvent call failed with exception, $e');

      rethrow;
    }
  }
}
