import 'package:brine/services/authentication/auth_session.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A fake [AuthSession] for use in tests.
///
/// Returns a preconfigured [User] (or null) without requiring Firebase platform initialization.
class FakeAuthSession implements AuthSession {
  /// Creates a [FakeAuthSession] with an optional mock user.
  const FakeAuthSession({this.currentUser});

  @override
  final User? currentUser;
}
