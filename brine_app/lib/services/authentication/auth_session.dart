import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_auth_session.dart';

/// Provides access to the current authenticated user session.
///
/// This abstraction decouples controllers from the `FirebaseAuth` singleton, allowing tests to inject a fake
/// implementation that returns controlled user data without requiring Firebase platform initialization.
///
// ignore: comment_references
/// In production, use [FirebaseAuthSession]. In tests, use [FakeAuthSession] or a custom implementation.
abstract class AuthSession {
  /// The currently authenticated user, or null if no user is signed in.
  User? get currentUser;
}
