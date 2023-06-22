import 'package:flutter/material.dart';

import '../../../../values/gifs.dart';
import '../../../values/insets.dart';

/// A GIF from the greatest science show, Bill Nye the Science Guy, inside a container with rounded corners.
class BillNyeGif extends StatelessWidget {
  const BillNyeGif({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color themeColor = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).primaryColorDark
        : Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: themeColor,
        border: Border.all(
          color: themeColor,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          Insets.kInsetsXSmall,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          child: Image.asset(
            Gifs.billNyeSalt.path,
            width: 400,
          ),
        ),
      ),
    );
  }
}
