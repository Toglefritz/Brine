import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../values/image_asset.dart';

/// An enumeration of error types that can be encountered in any part of the app.
///
/// This enumeration is used to categorize errors and provide specific error handling or user feedback based on the
/// type of error encountered. The errors in this enum span the entire app. Each error is associated with a specific
/// set of troubleshooting steps or user actions that can be taken to resolve the issue.
enum ErrorType {
  /// An error resulting from the user being unauthenticated when the app attempts to access cloud resources.
  unauthenticated,

  /// An error related to checking the Bluetooth permissions status. Note that this error is not necessarily related to
  /// Bluetooth permissions being denied. Rather, it is related to checking the status of the permissions.
  bluetoothPermissions,

  /// An error related to a failure to create a new account in Firebase Auth.
  firebaseAuthCreationFailed,

  /// An error related to a failure to create a new document for the user's account in Firestore. This error occurs
  /// after the user has successfully created an account in Firebase Auth.
  userDocumentCreationFailed,

  /// An error related to establishing a Bluetooth connection with a Brine device.
  bluetoothConnection,

  /// An error with an unknown cause.
  unknown;

  /// Returns a title for the error type, which can be used in screens communicating the error to the user.
  String errorTitle(BuildContext context) {
    switch (this) {
      case ErrorType.unauthenticated:
        return AppLocalizations.of(context)!.unauthenticatedErrorTitle;
      case ErrorType.bluetoothPermissions:
        return AppLocalizations.of(context)!.bluetoothPermissionsErrorTitle;
      case ErrorType.firebaseAuthCreationFailed:
        return AppLocalizations.of(context)!.firebaseAuthCreationErrorTitle;
      case ErrorType.userDocumentCreationFailed:
        return AppLocalizations.of(context)!.userDocumentCreationErrorTitle;
      case ErrorType.bluetoothConnection:
        return AppLocalizations.of(context)!.bluetoothConnectionErrorTitle;
      case ErrorType.unknown:
        return AppLocalizations.of(context)!.unknownErrorTitle;
    }
  }

  /// Returns an error message to be displayed to the user based on the error type.
  String errorMessage(BuildContext context) {
    switch (this) {
      case ErrorType.unauthenticated:
        return AppLocalizations.of(context)!.unauthenticatedError;
      case ErrorType.bluetoothPermissions:
        return AppLocalizations.of(context)!.bluetoothPermissionsError;
      case ErrorType.firebaseAuthCreationFailed:
        return AppLocalizations.of(context)!.firebaseAuthCreationError;
      case ErrorType.userDocumentCreationFailed:
        return AppLocalizations.of(context)!.userDocumentCreationError;
      case ErrorType.bluetoothConnection:
        return AppLocalizations.of(context)!.bluetoothConnectionError;
      case ErrorType.unknown:
        return AppLocalizations.of(context)!.unknownError;
    }
  }

  /// Returns an [ImageAsset] object to be displayed with each error message.
  ImageAsset errorImage() {
    switch (this) {
      case ErrorType.bluetoothConnection:
        return ImageAsset.bluetoothError;
      case ErrorType.unauthenticated:
      case ErrorType.bluetoothPermissions:
      case ErrorType.firebaseAuthCreationFailed:
      case ErrorType.userDocumentCreationFailed:
      case ErrorType.unknown:
        return ImageAsset.error;
    }
  }
}
