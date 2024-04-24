import 'package:flutter/material.dart';

import 'scan_route.dart';
import 'scan_view.dart';

/// Controller for the [ScanRoute].
class ScanController extends State<ScanRoute> {
  @override
  Widget build(BuildContext context) => ScanView(this);
}
