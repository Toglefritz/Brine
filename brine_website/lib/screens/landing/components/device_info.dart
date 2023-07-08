import 'package:brine/theme/insets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../values/assets.dart';

/// Displays information about the Brine device by showing an annotated image alongside a table with the
/// corresponding annotations.
///
/// The [direction] parameter determines whether the image and table are displayed in a row or a column.
class BrineInfo extends StatelessWidget {
  BrineInfo({
    super.key,
    required this.direction,
  });

  /// The direction, either horizontal or vertical, to show the image and corresponding table.
  final Axis direction;

  /// A list of assets to display on each row of the table where the index of the asset in the list
  /// corresponds to the row on which it should be displayed.
  final List<Assets> rowAssets = [
    Assets.numeral1,
    Assets.numeral2,
    Assets.numeral3,
  ];

  /// Returns the string to display on the row with the provided [index].
  String _getStringForRow({required int index, required BuildContext context}) {
    final Map<int, String> rowStrings = {
      0: AppLocalizations.of(context).mountingExplanation,
      1: AppLocalizations.of(context).sensorExplanation,
      2: AppLocalizations.of(context).batteryExplanation,
    };

    assert(rowStrings[index] != null, 'No string provided for device info row, $index');

    return rowStrings[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: Insets.medium,
          ),
          child: Image.asset(
            Assets.partsDiagram.path,
            width: 450,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.large,
          ),
          child: Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FixedColumnWidth(82),
              1: FixedColumnWidth(400),
            },
            border: TableBorder.all(
              borderRadius: const BorderRadius.all(
                Radius.circular(16.0),
              ),
              color: Theme.of(context).primaryColorDark,
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: List.generate(
              3,
              (index) => TableRow(
                children: <Widget>[
                  Image.asset(
                    rowAssets[index].path,
                    width: 40,
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(
                      Insets.small,
                    ),
                    child: Text(
                      _getStringForRow(index: index, context: context),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
