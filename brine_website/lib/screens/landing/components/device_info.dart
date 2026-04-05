import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import '../../../values/assets.dart';
import '../../../values/insets.dart';

/// Displays information about the Brine device by showing an annotated image alongside a table with the corresponding
/// annotations.
///
/// The [direction] parameter determines whether the image and table are displayed in a row or a column.
class DeviceInfo extends StatefulWidget {
  /// Creates a [DeviceInfo] widget.
  const DeviceInfo({
    required this.direction,
    super.key,
  });

  /// The direction, either horizontal or vertical, to show the image and corresponding table.
  final Axis direction;

  @override
  State<DeviceInfo> createState() => _DeviceInfoState();
}

class _DeviceInfoState extends State<DeviceInfo> {
  /// A list of assets to display on each row of the table where the index of the asset in the list corresponds to the
  /// row on which it should be displayed.
  final List<Asset> rowAssets = [
    Asset.numeral1,
    Asset.numeral2,
    Asset.numeral3,
  ];

  /// Returns the string to display on the row with the provided [index].
  String _getStringForRow({required int index, required BuildContext context}) {
    final Map<int, String> rowStrings = {
      0: AppLocalizations.of(context)!.mountingExplanation,
      1: AppLocalizations.of(context)!.sensorExplanation,
      2: AppLocalizations.of(context)!.batteryExplanation,
    };

    assert(rowStrings[index] != null, 'No string provided for device info row, $index');

    return rowStrings[index]!;
  }

  /// The index of the annotation over which the cursor is currently hovering.
  int? _hoverIndex;

  /// A callback for when the mouse enters the [MouseRegion]s over the annotations on the info diagram.
  void _onAnnotationEnter(int annotationIndex) {
    setState(() {
      _hoverIndex = annotationIndex;
    });
  }

  /// A callback for when the mouse enters the [MouseRegion]s over the annotations on the info diagram.
  void _onAnnotationExit() {
    setState(() {
      _hoverIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: widget.direction,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: Insets.medium,
          ),
          child: Stack(
            children: [
              Image.asset(
                Asset.partsDiagram.path,
                width: 450,
              ),
              Positioned(
                top: 17.2,
                left: 21.7,
                child: MouseRegion(
                  onEnter: (event) => _onAnnotationEnter(0),
                  onExit: (event) => _onAnnotationExit(),
                  cursor: SystemMouseCursors.click,
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
              Positioned(
                top: 152.1,
                left: 271.4,
                child: MouseRegion(
                  onEnter: (event) => _onAnnotationEnter(1),
                  onExit: (event) => _onAnnotationExit(),
                  cursor: SystemMouseCursors.click,
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
              Positioned(
                top: 84.5,
                left: 391.9,
                child: MouseRegion(
                  onEnter: (event) => _onAnnotationEnter(2),
                  onExit: (event) => _onAnnotationExit(),
                  cursor: SystemMouseCursors.click,
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
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
              width: 2.0,
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
                    padding: EdgeInsets.all(
                      Insets.small,
                    ),
                    child: Text(
                      _getStringForRow(index: index, context: context),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: index == _hoverIndex ? FontWeight.bold : FontWeight.normal,
                          ),
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
