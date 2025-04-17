/// An enumeration of error types that can be encountered in any part of the app.
///
/// This enumeration is used to categorize errors and provide specific error handling or user feedback based on the
/// type of error encountered. The errors in this enum span the entire app. Each error is associated with a specific
/// set of troubleshooting steps or user actions that can be taken to resolve the issue.
enum ErrorType {
  /// An error resulting from the user being unauthenticated when the app attempts to access cloud resources.
  unauthenticated,

  /// An error with an unknown cause.
  unknown;
}
