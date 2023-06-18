import 'package:brine/screens/welcome/welcome_route.dart';
import 'package:brine/screens/welcome/welcome_view.dart';
import 'package:flutter/material.dart';

/// Controller for [WelcomeRoute].
class WelcomeController extends State<WelcomeRoute> {
  /// Handles taps on the [AddDeviceButton] button located on the [WelcomeView].
  void onAddDevicePressed() {
    // TODO implementation
  }

  /// Handles taps on the button allowing a user to order Brine
  void onOrderButtonPressed() {
    // TODO implementation
  }

  @override
  Widget build(BuildContext context) => WelcomeView(this);
}
