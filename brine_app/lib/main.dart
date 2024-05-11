import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'brine_app.dart';
import 'firebase_options.dart';

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

  // In debug mode, use the Firebase local emulator
  if (kDebugMode) {
    try {
      // The IP address of the machine running the Firebase emulator suite. Use "localhost" if running the emulator
      // suite on the same machine as the app. Otherwise, use the IP address of the machine running the emulator suite.
      // The emulator suite can be started with the command `firebase emulators:start`.
      // The IP address of the machine running the emulator suite will be displayed in the terminal.
      const String devMachineIP = '192.168.86.28';

      FirebaseFirestore.instance.useFirestoreEmulator(devMachineIP, 8080);
      await FirebaseAuth.instance.useAuthEmulator(devMachineIP, 9099);
      FirebaseFunctions.instance.useFunctionsEmulator(devMachineIP, 5001);

      debugPrint('Using Firebase emulator suite');
    } catch (e) {
      debugPrint('Firebase emulator initialization failed with exception, $e');
    }
  }

  runApp(const BrineApp());
}
