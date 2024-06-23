import 'package:brine/services/device_management/firebase_emulators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'brine_app.dart';
import 'firebase_options.dart';

/// The entry point of the application.
///
/// The [main] function initializes Firebase and Firebase AppCheck before running the [BrineApp] widget. If the app is
/// running in debug mode, the Firebase local emulator suite is used.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase AppCheck
  if (kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } else {
    await FirebaseAppCheck.instance.activate();
  }

  // In debug mode, use the Firebase local emulator.
  if (kDebugMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator(devMachineIP, 8080);
      await FirebaseAuth.instance.useAuthEmulator(devMachineIP, 9099);
      FirebaseFunctions.instance.useFunctionsEmulator(devMachineIP, 5001);

      debugPrint('Using Firebase emulator suite');
    } catch (e) {
      debugPrint('Firebase emulator initialization failed with exception, $e');
    }
  }

  if (!kDebugMode) {
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(const BrineApp());
}
