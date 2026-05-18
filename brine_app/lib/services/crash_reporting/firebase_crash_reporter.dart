import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'crash_reporter.dart';

/// Production implementation of [CrashReporter] that delegates to Firebase Crashlytics.
class FirebaseCrashReporter implements CrashReporter {
  /// Creates an instance of [FirebaseCrashReporter].
  const FirebaseCrashReporter();

  // coverage:ignore-start
  @override
  Future<void> recordError(dynamic exception, StackTrace stackTrace) {
    return FirebaseCrashlytics.instance.recordError(exception, stackTrace);
  }
  // coverage:ignore-end
}
