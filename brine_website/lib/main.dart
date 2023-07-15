import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'brine_monitor_website.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase services
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // In debug mode, use the Firebase emulator
  if (kDebugMode) {
    try {
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    } catch (e) {
      debugPrint('Failed to initialize Firebase emulators with exception, $e');
    }
  }

  // Persist the authentication state, even when the browser is closed
  FirebaseAuth auth = FirebaseAuth.instance;
  auth.setPersistence(Persistence.LOCAL);
  if (kIsWeb) {
    await FirebaseAuth.instance.authStateChanges().first;
  }

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(const BrineMonitorWebsite());
}
