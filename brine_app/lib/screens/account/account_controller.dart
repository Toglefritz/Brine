import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/analytics/analytics.dart';
import '../../services/authentication/authentication_service.dart';
import 'account_route.dart';
import 'account_view.dart';

/// Controller for the [AccountRoute].
class AccountController extends State<AccountRoute> {
  /// A convenience getter for the Firebase Auth user object.
  User? get user => FirebaseAuth.instance.currentUser;

  /// A convenience getter for the user's initials.
  String get userInitials {
    if (user == null) {
      return '';
    }

    // Split the user's display name their first and last names.
    final List<String> nameParts = user!.displayName!.split(' ');

    // Get the first letter of the user's first name.
    final String firstName = nameParts.first;

    // Get the first letter of the user's last name, if it exists.
    final String lastName = nameParts.length > 1 ? nameParts.last : '';

    // Return a string consisting of the first letters of the user's first and last names.
    return '${firstName[0]}${lastName[0]}';
  }

  /// Handles taps on the "logout" button.
  Future<void> logout() async {
    Analytics.trackLogout();

    await AuthenticationService.signOut();
  }

  @override
  Widget build(BuildContext context) => AccountView(this);
}
