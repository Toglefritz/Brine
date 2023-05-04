import 'package:flutter/material.dart';

import '../../../../values/gifs.dart';

/// A GIF from the greatest movie ever, Anchorman, inside a container with rounded corners.
class BillNyeGif extends StatelessWidget {
  const BillNyeGif({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        border: Border.all(
          color: Theme.of(context).primaryColorDark,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
        child: Image.asset(
          Gifs.billNyeSalt.path,
          width: 500,
        ),
      ),
    );
  }
}
