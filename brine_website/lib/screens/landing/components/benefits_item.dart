import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// An individual item in the [BenefitsInfo] widget consisting of an [icon], and [title], and
/// a [description].
class BenefitsItem extends StatelessWidget {
  const BenefitsItem({
    super.key,
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
  });

  /// The width of the item.
  final double width;

  /// An icon or image displayed on the top of the [BenefitsItem].
  final Widget icon;

  /// A title for the [BenefitsItem] displayed below the [icon].
  final String title;

  /// A description of the benefits item displayed below the [title].
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          icon,
          Text(
            title,
            style: GoogleFonts.changaOne().copyWith(
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
