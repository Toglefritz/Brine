import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'brine_monitor_website.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase services
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BrineMonitorWebsite());
}
