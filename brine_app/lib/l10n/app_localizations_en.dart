// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get account => 'Account';

  @override
  String get accountControls => 'Account Controls';

  @override
  String get addADevice => 'Add a device';

  @override
  String get addDeviceInvitation =>
      'Get started by linking your Brine device to the app.';

  @override
  String get and => ' and ';

  @override
  String get associatingDevice => 'Associating to account...';

  @override
  String get back => 'back';

  @override
  String get batteryLevel => 'Battery Level';

  @override
  String get bleConnecting => 'Establishing connection...';

  @override
  String get bluetoothConnectionError =>
      'We had a bit of trouble connecting to your Brine device over Bluetooth. Make sure it\'s powered on, nearby, and ready to pair, then give it another try.';

  @override
  String get bluetoothConnectionErrorTitle => 'Bluetooth Connection Failed';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get bluetoothPermissionsError =>
      'Bluetooth permissions are required to set up your Brine device. Once your Brine device is ready to go, feel free to switch it off again if you prefer.';

  @override
  String get bluetoothPermissionsErrorTitle => 'Bluetooth Permissions Required';

  @override
  String get brine => 'Brine';

  @override
  String get brineDevices => 'Brine Devices';

  @override
  String get chooseAnother => 'Choose another';

  @override
  String get completingSetup => 'Completing setup...';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get continueText => 'Continue';

  @override
  String get createAccount => 'create account';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account?';

  @override
  String get detectedDeviceConfirmation =>
      'Is this the device you wish to add?';

  @override
  String get device => 'Device';

  @override
  String get deviceDetected => 'Device detected';

  @override
  String get deviceOverdueMessageDescription =>
      'It has been a while since your Brine device has sent an update. It appears to be offline.';

  @override
  String get deviceId => 'Device ID';

  @override
  String deviceOverdueMessage(String timestamp) {
    return 'Last updated: $timestamp';
  }

  @override
  String get displayName => 'Display name';

  @override
  String get displayNameRequired => 'Display name is required';

  @override
  String get displayNameUpdateFailed => 'Failed to update display name';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get email => 'Email';

  @override
  String get emailInvalid => 'Email is invalid';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailUpdateFailed => 'Failed to update email';

  @override
  String emailUpdateDialogMessage(String email) {
    return 'We\'ve sent a confirmation email to $email. Please click the link in the email to confirm your new email address.';
  }

  @override
  String get emailUpdateDialogTitle => 'Confirmation required';

  @override
  String get firebaseAuthCreationError =>
      'Something went wrong while setting up your login credentials. This could be due to a network hiccup, an issue with the email or password, or just some temporary turbulence. Just give it another go, and if the problem sticks around, our team is here to help and they have, in fact, already been alerted.';

  @override
  String get firebaseAuthCreationErrorTitle =>
      'We Hit a Snag Creating Your Account';

  @override
  String get getOneNow => 'Get one now';

  @override
  String get heightMeasurementTitle => 'Height Measurement';

  @override
  String get installationTitle => 'Install Brine';

  @override
  String get lastUpdated => 'Last Updated';

  @override
  String get login => 'login';

  @override
  String get loginWithApple => 'login with Apple';

  @override
  String get loginWithGoogle => 'login with Google';

  @override
  String get logout => 'Logout';

  @override
  String get newPassword => 'New password';

  @override
  String get noDevicesFoundMessage => 'No devices found';

  @override
  String get noNetworksDetected => 'No networks detected';

  @override
  String get noDevicesFoundDescription =>
      'Please make sure your Brine device is powered on, nearby, and that you\'ve pressed the pairing button. The light on the Brine monitor should be blinking.';

  @override
  String get ok => 'OK';

  @override
  String get onboardingLegalPrompt1 => 'Please take a look at our ';

  @override
  String get onboardingLegalPrompt2 => ' before using this app.';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password is too short (minimum 8 characters)';

  @override
  String get passwordUpdateFailed => 'Failed to update password';

  @override
  String get performingPskSetup => 'Performing security setup...';

  @override
  String get privacyPolicy => 'privacy policy';

  @override
  String get profile => 'Profile';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully';

  @override
  String get reauthenticationFailed =>
      'Authentication failed. We are unable to update your account information at this time.';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get remove => 'Remove';

  @override
  String get removeDevice => 'Remove device';

  @override
  String removeDeviceConfirmation(String deviceId) {
    return 'Are you sure you want to remove the Brine device with ID, \"$deviceId\", from your account?';
  }

  @override
  String get saltRemaining => 'Salt Remaining';

  @override
  String get scanningMessage => 'Scanning for devices...';

  @override
  String get security => 'Security';

  @override
  String get setupComplete => 'Setup complete';

  @override
  String get signUpWithApple => 'sign up with Apple';

  @override
  String get signUpWithGoogle => 'sign up with Google';

  @override
  String get salesPrompt => 'Don\'t have a Brine device?';

  @override
  String get saltLevel => 'Salt Level';

  @override
  String get save => 'Save';

  @override
  String get saveText => 'Save';

  @override
  String get submit => 'Submit';

  @override
  String get termsOfService => 'terms of service';

  @override
  String get tryAgain => 'Try again';

  @override
  String get unauthenticatedError =>
      'Your session has expired. Please log in again.';

  @override
  String get unauthenticatedErrorTitle => 'Authentication Error';

  @override
  String get unknownError =>
      'Yikes! A mysterious glitch just occurred. The Brine team has been alerted and will get things sorted out ASAP. Thanks for your patience!';

  @override
  String get unknownErrorTitle => 'Oh no!';

  @override
  String get username => 'Username (email)';

  @override
  String get userDocumentCreationError =>
      'Your account was created, but we couldn’t finish setting up your profile behind the scenes. This is likely a temporary issue, and the Brine team has already been alerted. You can try again in a moment, and we’ll make sure everything’s running smoothly.';

  @override
  String get userDocumentCreationErrorTitle => 'Almost There… But Not Quite';

  @override
  String get waterSoftenerHeight => 'Water softener height';

  @override
  String get wifiSetup => 'WiFi Setup';

  @override
  String get wifiConnecting => 'Connecting to WiFi...';

  @override
  String get wifiSetupInstructions =>
      'Select the WiFi network to which your Brine monitor should connect.';
}
