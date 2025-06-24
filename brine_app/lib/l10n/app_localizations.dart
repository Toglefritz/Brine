import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// A title for the account/profile information screen.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Title for a section of the account settings screen containing account management controls.
  ///
  /// In en, this message translates to:
  /// **'Account Controls'**
  String get accountControls;

  /// Text for a button that allows the user to add a device to their account.
  ///
  /// In en, this message translates to:
  /// **'Add a device'**
  String get addADevice;

  /// Text inviting the user to link their Brine device to the app.
  ///
  /// In en, this message translates to:
  /// **'Get started by linking your Brine device to the app.'**
  String get addDeviceInvitation;

  /// Text used to separate two items in a list.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// Text displayed while the app is associating a device to the user's account.
  ///
  /// In en, this message translates to:
  /// **'Associating to account...'**
  String get associatingDevice;

  /// Text for a button that allows the user to navigate back to the previous screen.
  ///
  /// In en, this message translates to:
  /// **'back'**
  String get back;

  /// Label for the battery level of the Brine device.
  ///
  /// In en, this message translates to:
  /// **'Battery Level'**
  String get batteryLevel;

  /// Text displayed while the app is establishing a Bluetooth connection to a device.
  ///
  /// In en, this message translates to:
  /// **'Establishing connection...'**
  String get bleConnecting;

  /// Generic text for a button that allows the user to cancel an action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Text indicating that a process has been completed.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Error message displayed when the app does not have the required Bluetooth permissions.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permissions are required to set up your Brine device. Once your Brine device is ready to go, feel free to switch it off again if you prefer.'**
  String get bluetoothPermissionsError;

  /// Title for the error message displayed when the app does not have the required Bluetooth permissions.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Permissions Required'**
  String get bluetoothPermissionsErrorTitle;

  /// The name of the app and the product.
  ///
  /// In en, this message translates to:
  /// **'Brine'**
  String get brine;

  /// Title for the screen where the user can view and manage their Brine devices.
  ///
  /// In en, this message translates to:
  /// **'Brine Devices'**
  String get brineDevices;

  /// Text for a button allowing the user to select a different Brine device from the Bluetooth scan
  ///
  /// In en, this message translates to:
  /// **'Choose another'**
  String get chooseAnother;

  /// Text displayed while the app is completing the setup process at the end of the provisioning flow.
  ///
  /// In en, this message translates to:
  /// **'Completing setup...'**
  String get completingSetup;

  /// Label for the field where the user must confirm their password.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// Text for a button that allows the user to continue to the next screen or to continue with a process.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// Text for a button that allows the user to create an account.
  ///
  /// In en, this message translates to:
  /// **'create account'**
  String get createAccount;

  /// Generic text for a button that allows the user to delete an item.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Title for the screen where the user can delete their account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Confirmation message asking the user if they are sure they want to delete their account.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteAccountConfirmation;

  /// Text asking the user to confirm that the detected device is the one they wish to add.
  ///
  /// In en, this message translates to:
  /// **'Is this the device you wish to add?'**
  String get detectedDeviceConfirmation;

  /// A generic label for a field related to a device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// Text displayed when the app detects a Brine device.
  ///
  /// In en, this message translates to:
  /// **'Device detected'**
  String get deviceDetected;

  /// Description of the message displayed when the app has not received an update from the Brine device in a while.
  ///
  /// In en, this message translates to:
  /// **'It has been a while since your Brine device has sent an update. It appears to be offline.'**
  String get deviceOverdueMessageDescription;

  /// Label for the unique identifier of the Brine device.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceId;

  /// Message displayed when the app has not received an update from the Brine device in a while.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {timestamp}'**
  String deviceOverdueMessage(String timestamp);

  /// Label for the field where the user must enter a display name.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// Error message displayed when the user tries to submit a form without entering a display name.
  ///
  /// In en, this message translates to:
  /// **'Display name is required'**
  String get displayNameRequired;

  /// Error message displayed when the app fails to update the user's display name.
  ///
  /// In en, this message translates to:
  /// **'Failed to update display name'**
  String get displayNameUpdateFailed;

  /// Title for the screen where the user can edit their account information.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// Label for the field where the user must enter their email address.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Error message displayed when the user enters an invalid email address.
  ///
  /// In en, this message translates to:
  /// **'Email is invalid'**
  String get emailInvalid;

  /// Error message displayed when the user tries to submit a form without entering an email address.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Error message displayed when the app fails to update the user's email address.
  ///
  /// In en, this message translates to:
  /// **'Failed to update email'**
  String get emailUpdateFailed;

  /// Message displayed in the dialog explaining the process for confirming a change to the user's email.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a confirmation email to {email}. Please click the link in the email to confirm your new email address.'**
  String emailUpdateDialogMessage(String email);

  /// Title for the dialog explaining the process for confirming a change to the user's email
  ///
  /// In en, this message translates to:
  /// **'Confirmation required'**
  String get emailUpdateDialogTitle;

  /// Text for a button that allows the user to purchase a Brine device.
  ///
  /// In en, this message translates to:
  /// **'Get one now'**
  String get getOneNow;

  /// Title for the screen where the user can measure the height of their water softener.
  ///
  /// In en, this message translates to:
  /// **'Height Measurement'**
  String get heightMeasurementTitle;

  /// Title for the screen presenting the installation instructions for the Brine device.
  ///
  /// In en, this message translates to:
  /// **'Install Brine'**
  String get installationTitle;

  /// Label for the date and time when the Brine device last sent an update.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// Text for a button that allows the user to log in to their account.
  ///
  /// In en, this message translates to:
  /// **'login'**
  String get login;

  /// Text for a button that allows the user to log in with their Apple account.
  ///
  /// In en, this message translates to:
  /// **'login with Apple'**
  String get loginWithApple;

  /// Text for a button that allows the user to log in with their Google account.
  ///
  /// In en, this message translates to:
  /// **'login with Google'**
  String get loginWithGoogle;

  /// Text for a button that allows the user to log out of their account.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Label for the field where the user must enter a new password.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @noDevicesFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevicesFoundMessage;

  /// Error text displayed when the app does not detect any Brine devices via Bluetooth nearby.
  ///
  /// In en, this message translates to:
  /// **'No networks detected'**
  String get noNetworksDetected;

  /// Error text displayed when the app does not detect any Brine devices via Bluetooth nearby.
  ///
  /// In en, this message translates to:
  /// **'Please make sure your Brine device is powered on, nearby, and that you\'ve pressed the pairing button. The light on the Brine monitor should be blinking.'**
  String get noDevicesFoundDescription;

  /// Generic text for a button that allows the user to confirm an action.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// The first part of a prompt asking the user to review the app's legal agreements before using the app
  ///
  /// In en, this message translates to:
  /// **'Please take a look at our '**
  String get onboardingLegalPrompt1;

  /// The second part of a prompt asking the user to review the app's legal agreements before using the app
  ///
  /// In en, this message translates to:
  /// **' before using this app.'**
  String get onboardingLegalPrompt2;

  /// Label for the field where the user must enter their password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Error message displayed when the user tries to submit a form without entering a password.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Error message displayed when the user enters a password that is too short.
  ///
  /// In en, this message translates to:
  /// **'Password is too short (minimum 8 characters)'**
  String get passwordTooShort;

  /// Error message displayed when the app fails to update the user's password.
  ///
  /// In en, this message translates to:
  /// **'Failed to update password'**
  String get passwordUpdateFailed;

  /// Text displayed while the app is performing the security setup process.
  ///
  /// In en, this message translates to:
  /// **'Performing security setup...'**
  String get performingPskSetup;

  /// Text for a button that allows the user to view the privacy policy.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get privacyPolicy;

  /// Title for a screen where the user can view and edit their profile information.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Success message displayed when the user's profile information is updated successfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdateSuccess;

  /// Error message displayed when the app fails to reauthenticate the user.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. We are unable to update your account information at this time.'**
  String get reauthenticationFailed;

  /// Text for a button that allows the user to reconnect to an offline device.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// Generic text for a button that allows the user to remove an item.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Text for a button that allows the user to remove a device from their account.
  ///
  /// In en, this message translates to:
  /// **'Remove device'**
  String get removeDevice;

  /// Confirmation message asking the user if they are sure they want to remove a device from their account.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the Brine device with ID, \"{deviceId}\", from your account?'**
  String removeDeviceConfirmation(String deviceId);

  /// Label for the amount of salt remaining in the water softener.
  ///
  /// In en, this message translates to:
  /// **'Salt Remaining'**
  String get saltRemaining;

  /// Text displayed while the app is scanning for Brine devices.
  ///
  /// In en, this message translates to:
  /// **'Scanning for devices...'**
  String get scanningMessage;

  /// Title for a profile screen where the user can set up security settings.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Text displayed when the setup process is complete.
  ///
  /// In en, this message translates to:
  /// **'Setup complete'**
  String get setupComplete;

  /// Text for a button that allows the user to sign up with their Apple account.
  ///
  /// In en, this message translates to:
  /// **'sign up with Apple'**
  String get signUpWithApple;

  /// Text for a button that allows the user to sign up with their Google account.
  ///
  /// In en, this message translates to:
  /// **'sign up with Google'**
  String get signUpWithGoogle;

  /// Marketing prompt text inviting the user to purchase a Brine device.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a Brine device?'**
  String get salesPrompt;

  /// Label for the salt level in the water softener.
  ///
  /// In en, this message translates to:
  /// **'Salt Level'**
  String get saltLevel;

  /// Text for a button that allows the user to save changes.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Text for a button that allows the user to save changes.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveText;

  /// Text for a button that allows the user to submit a form.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Text for a button that allows the user to view the terms of service.
  ///
  /// In en, this message translates to:
  /// **'terms of service'**
  String get termsOfService;

  /// Text for a button that allows the user to try an action again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Error message displayed when the user's session has expired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get unauthenticatedError;

  /// Title for the error message displayed when the user's session has expired.
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get unauthenticatedErrorTitle;

  /// Error message displayed when an unknown error occurs.
  ///
  /// In en, this message translates to:
  /// **'Yikes! A mysterious glitch just occurred. The Brine team has been alerted and will get things sorted out ASAP. Thanks for your patience!'**
  String get unknownError;

  /// No description provided for @unknownErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Oh no!'**
  String get unknownErrorTitle;

  /// Label for the field where the user must enter their username.
  ///
  /// In en, this message translates to:
  /// **'Username (email)'**
  String get username;

  /// Label for field used to collect the height of the water softener.
  ///
  /// In en, this message translates to:
  /// **'Water softener height'**
  String get waterSoftenerHeight;

  /// Title for the screen where the user can set up the WiFi connection for their Brine device.
  ///
  /// In en, this message translates to:
  /// **'WiFi Setup'**
  String get wifiSetup;

  /// Text displayed while the Brine monitor is connecting to a WiFi network.
  ///
  /// In en, this message translates to:
  /// **'Connecting to WiFi...'**
  String get wifiConnecting;

  /// Instructions for the user to select the WiFi network to which their Brine device should connect.
  ///
  /// In en, this message translates to:
  /// **'Select the WiFi network to which your Brine monitor should connect.'**
  String get wifiSetupInstructions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
