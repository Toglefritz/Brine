import 'package:firebase_auth/firebase_auth.dart';

import 'auth_session.dart';

/// Production implementation of [AuthSession] that delegates to the Firebase Auth singleton.
///
/// This is the default session provider used throughout the app when no test override is injected.
class FirebaseAuthSession implements AuthSession {
  /// Creates an instance of [FirebaseAuthSession].
  const FirebaseAuthSession();

  @override
  User? get currentUser => FirebaseAuth.instance.currentUser;
}
