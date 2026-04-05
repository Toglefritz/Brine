import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../themes/dark_theme_provider.dart';

/// A [Switch] used to toggle between a light and dark theme for the app/website.
class DarkThemeToggle extends StatelessWidget {
  /// Creates an instance of [DarkThemeToggle].
  const DarkThemeToggle({
    required this.onChanged,
    super.key,
  });

  /// The callback function triggered when the toggle is changed.
  final void Function({required BuildContext context, required bool isActive}) onChanged;

  @override
  Widget build(BuildContext context) {
    final bool darkTheme = Provider.of<DarkThemeProvider>(context).darkTheme;

    return Switch(
      value: darkTheme,
      thumbIcon: WidgetStateProperty.resolveWith(
        (_) {
          if (darkTheme) {
            return Icon(
              Icons.brightness_7,
              color: Theme.of(context).primaryColorLight,
            );
          }
          return const Icon(Icons.brightness_2_outlined);
        },
      ),
      inactiveThumbColor: Theme.of(context).primaryColorDark,
      activeThumbColor: Theme.of(context).primaryColor,
      onChanged: (isActive) => onChanged(
        isActive: isActive,
        context: context,
      ),
    );
  }
}
