import 'package:brine/services/crash_reporting/crash_reporter.dart';

/// A [CrashReporter] that does nothing, for use in tests.
///
/// Prevents tests from requiring Firebase Crashlytics initialization.
class NoOpCrashReporter implements CrashReporter {
  /// Creates an instance of [NoOpCrashReporter].
  const NoOpCrashReporter();

  @override
  Future<void> recordError(dynamic exception, StackTrace stackTrace) async {}
}
