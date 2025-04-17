import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/device_management/models/brine_device.dart';
import '../../../theme/insets.dart';

/// A card widget that expands when tapped to reveal additional information
/// about an IoT device.
///
/// This widget initially displays only the device's name. When tapped, the card smoothly increases in height, revealing
/// details such as salt level, battery level, and last updated timestamp.
///
/// Example usage:
/// ```dart
/// ExpandableDeviceCard(
///   name: "Brine Device 1",
///   saltLevel: 0.75,
///   batteryLevel: 90,
///   lastUpdatedTimestamp: "2025-01-30 12:00 PM",
/// )
/// ```
class ExpandableDeviceCard extends StatefulWidget {
  /// The Brine device associated with this card.
  final BrineDevice device;

  /// A callback function invoked when the delete button is tapped.
  final VoidCallback onRemoveDevice;

  /// Creates an instance of [ExpandableDeviceCard].
  ///
  /// All parameters are required to provide complete information about the device.
  const ExpandableDeviceCard({
    required this.device,
    required this.onRemoveDevice,
    super.key,
  });

  @override
  ExpandableDeviceCardState createState() => ExpandableDeviceCardState();
}

/// The state class for [ExpandableDeviceCard].
///
/// Manages the expansion and collapse of the card when tapped, animating the height change to smoothly reveal
/// additional details.
class ExpandableDeviceCardState extends State<ExpandableDeviceCard> {
  /// Whether the card is currently expanded.
  bool _isExpanded = false;

  /// Determines if the content within the card should be displayed.
  bool _isContentVisible = false;

  /// The duration of the animation when expanding or collapsing the card.
  static const Duration _cardAnimationDuration = Duration(milliseconds: 300);

  /// The duration of the animation when showing or hiding the content within the card.
  static const Duration _contentAnimationDuration = Duration(milliseconds: 200);

  /// Toggles the expansion state of the card.
  ///
  /// When the card is tapped, this method is called to either expand or collapse the card, and show or hide the
  /// content within the card. The order in which the card is expanded or collapsed and the content is shown or hidden
  /// is important to ensure a smooth transition.
  ///
  /// If the card is going from expanded to collapsed, the content is hidden first, then the card is collapsed. If the
  /// card is going from collapsed to expanded, the card is expanded first, then the content is shown.
  void _toggleExpanded() {
    // If the card is going from expanded to collapsed, hide the content first.
    if (_isExpanded) {
      setState(() {
        _isContentVisible = false;
      });

      // Wait before toggling the expansion state to allow the content to fade out. If the
      Future<void>.delayed(_contentAnimationDuration, () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      });
    }
    // If the card is going from collapsed to expanded, first toggle the expansion state.
    else {
      setState(() {
        _isExpanded = !_isExpanded;
      });

      // Wait before showing the content to allow the card to expand.
      Future<void>.delayed(_cardAnimationDuration, () {
        setState(() {
          _isContentVisible = _isExpanded;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          AnimatedContainer(
            duration: _cardAnimationDuration,
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(Insets.medium),
            height:
                _isExpanded ? MediaQuery.textScalerOf(context).scale(190) : MediaQuery.textScalerOf(context).scale(100),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            // Prevents small pixel overflows
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Insets.xLarge),
                  child: Text(
                    widget.device.name,
                    style: GoogleFonts.bungee().copyWith(
                      fontSize: 36,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: _contentAnimationDuration,
                  child: _isContentVisible
                      ? Column(
                          key: ValueKey<bool>(_isExpanded),
                          children: [
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: '${AppLocalizations.of(context)!.deviceId}: ',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  TextSpan(
                                    text: widget.device.deviceId,
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: '${AppLocalizations.of(context)!.saltLevel}: ',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  TextSpan(
                                    text: '${(widget.device.saltLevel * 100).toInt()}%',
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: '${AppLocalizations.of(context)!.batteryLevel}: ',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  TextSpan(
                                    text: '${widget.device.batteryLevel.toInt()}%',
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: '${AppLocalizations.of(context)!.lastUpdated}: ',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  TextSpan(
                                    text: widget.device.lastUpdateTime,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),

          // A button used to remove the device from the user's account.
          if (_isExpanded)
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red[900],
              ),
              onPressed: widget.onRemoveDevice,
            ),
        ],
      ),
    );
  }
}
