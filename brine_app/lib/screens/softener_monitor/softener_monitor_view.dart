import 'package:brine/screens/softener_monitor/softener_monitor_controller.dart';
import 'package:flutter/material.dart';

/// View for [SoftenerMonitorRoute].
class SoftenerMonitorView extends StatelessWidget {
  final SoftenerMonitorController state;

  const SoftenerMonitorView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brine'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[],
        ),
      ),
    );
  }
}
