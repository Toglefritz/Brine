import 'package:flutter/material.dart';

import '../../../../values/gifs.dart';
import '../../../values/insets.dart';

/// A GIF showing a super cute little frog saying "thanks," inside a container with rounded corners.
class ThanksFrogGif extends StatelessWidget {
  const ThanksFrogGif({
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
            Radius.circular(10),
          ),
          child: Image.asset(
            Gifs.thanksFrog.path,
            width: 400,
          ),
        ),
      ),
    );
  }
}
