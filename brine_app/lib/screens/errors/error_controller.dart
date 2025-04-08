import 'package:flutter/material.dart';

import '../../services/analytics/analytics.dart';
import 'error_route.dart';
import 'error_view.dart';

/// Controller for the [ErrorRoute].
class ErrorController extends State<ErrorRoute> {
  @override
  void initState() {
    Analytics.trackPageView('error');

    super.initState();
  }

  @override
  Widget build(BuildContext context) => ErrorView(this);
}
