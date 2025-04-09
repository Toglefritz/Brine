import 'package:flutter/material.dart';

/// A wrapper around [State] that overrides the [setState] and [Navigator] methods to check [mounted] before calling
/// the methods.
///
/// Calling [setState] after the controller, or other class extending [State], is disposed results in, at best, an
/// exception being thrown by the Flutter SDK and, at worst, an app crash. [SafeState] is a wrapper around [State] that
/// overrides the [setState] class in order to check [mounted] before calling [setState]. To use this class, extend
/// [SafeState] where you would normally extend [State] directly.
///
/// Similarly, [SafeState] contains the methods, [push], [pushReplacement], [pushAndRemoveUntil], and [pop], that are
/// wrappers around [Navigator.push], [Navigator.pushReplacement], [Navigator.pushAndRemoveUntil], and [Navigator.pop],
/// respectively. These methods check the [mounted] boolean before calling the calls the [Navigator]'s methods within.
///
/// In general, it is safest to use the [SafeState] method for any class that extends [State] because, even if there is
/// no risk in checking for [mounted] before calling [setState] or the [Navigator] methods, it also does not hurt
/// to do so. Performing these checks on [mounted] help to reduce the risk of exceptions and app crashes.
abstract class SafeState<T extends StatefulWidget> extends State<T> {
  /// Overrides the [setState] method to check the [mounted] boolean before calling [super.setState].
  @override
  void setState(void Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  /// Checks the [mounted] boolean before performing calls to [Navigator.pushReplacement].
  Future<dynamic> pushReplacement(Route<void> route) async {
    if (!mounted) return;

    return Navigator.pushReplacement(context, route);
  }

  /// Checks the [mounted] boolean before performing calls to [Navigator.push].
  Future<dynamic> push(Route<void> route) async {
    if (!mounted) return;

    return Navigator.push(context, route);
  }

  /// Checks the [mounted] boolean before performing calls to [Navigator.pop].
  void pop([dynamic data]) {
    if (!mounted) return;

    Navigator.pop(context, data);
  }

  /// Checks the [mounted] boolean before performing calls to [Navigator.pushAndRemoveUntil].
  void pushAndRemoveUntil(Route<void> route, RoutePredicate predicate) {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(context, route, predicate);
  }
}
