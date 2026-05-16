part of 'error_route.dart';

/// Controller for the [ErrorRoute].
class ErrorController extends State<ErrorRoute> {
  @override
  void initState() {
    Analytics.trackPageView('error');

    super.initState();
  }

  /// Returns the appropriate action for the current error type, if any.
  ErrorAction? getErrorAction() {
    switch (widget.errorType) {
      case ErrorType.unauthenticated:
        return ErrorAction(
          label: AppLocalizations.of(context)!.login,
          onPressed: _onLoginAgain,
        );
      case ErrorType.bluetoothPermissions:
        return null;
      case ErrorType.firebaseAuthCreationFailed:
        return ErrorAction(
          label: AppLocalizations.of(context)!.tryAgain,
          onPressed: _onLoginAgain,
        );
      case ErrorType.userDocumentCreationFailed:
        return null;
      case ErrorType.bluetoothConnection:
        return ErrorAction(
          label: AppLocalizations.of(context)!.tryAgain,
          onPressed: _onRetryBluetoothConnection,
        );
      case ErrorType.unknown:
        return null; // No action for unknown errors
    }
  }

  /// Handles taps on the button used to log into the Brine app again following an authentication error.
  Future<void> _onLoginAgain() async {
    // First ensure that the current session is disposed.
    await AuthenticationService.signOut();

    // Navigate to the onboarding route.
    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const OnboardingRoute(),
      ),
    );
  }

  /// Handles retrying Bluetooth connection.
  Future<void> _onRetryBluetoothConnection() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const ScanRoute(
          excludedDeviceNames: [], // By definition, there are no excluded devices from this route
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ErrorView(this);
}
