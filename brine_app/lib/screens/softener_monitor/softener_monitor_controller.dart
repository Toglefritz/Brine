import 'dart:async';
import 'dart:math';

import 'package:brine/screens/softener_monitor/softener_monitor_route.dart';
import 'package:brine/screens/softener_monitor/softener_monitor_view.dart';
import 'package:flutter/material.dart';

/// Controller for [SoftenerMonitorRoute].
class SoftenerMonitorController extends State<SoftenerMonitorRoute> {
  double testProgress = 0.2;

  double _generateRandomDouble(double minValue, double maxValue) {
    if (maxValue < minValue) {
      throw ArgumentError('maxValue should be greater than or equal to minValue');
    }

    final random = Random();
    return minValue + random.nextDouble() * (maxValue - minValue);
  }

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 4), (timer) {
      setState(() {
        testProgress = _generateRandomDouble(0.1, 0.9);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SoftenerMonitorView(this);
}
