import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../themes/dark_theme_provider.dart';

/// A [Switch] used to toggle between a light and dark theme for the app/website.
class DarkThemeToggle extends StatelessWidget {
  const DarkThemeToggle({
    super.key,
    required this.onChanged,
  });

  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    bool darkTheme = Provider.of<DarkThemeProvider>(context).darkTheme;

    return Switch(
      value: darkTheme,
      thumbIcon: MaterialStateProperty.resolveWith(
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
      activeColor: Theme.of(context).primaryColor,
      onChanged: (newValue) => onChanged(newValue),
    );
  }
}
