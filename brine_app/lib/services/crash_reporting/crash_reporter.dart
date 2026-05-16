// ignore_for_file: one_member_abstracts

import 'firebase_crash_reporter.dart';

/// Abstraction for crash and error reporting.
///
/// Decouples controllers from the `FirebaseCrashlytics` singleton, allowing tests to run without Firebase platform
/// initialization. In production, use [FirebaseCrashReporter].
abstract class CrashReporter {
  /// Records a non-fatal error for analysis.
  Future<void> recordError(dynamic exception, StackTrace stackTrace);
}
