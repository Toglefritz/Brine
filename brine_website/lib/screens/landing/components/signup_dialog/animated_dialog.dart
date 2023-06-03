import 'package:flutter/material.dart';

/// An animated dialog widget that slides from the lower right corner of the screen to the middle when opened.
///
/// This widget extends StatefulWidget and uses a SlideTransition to animate the widget's entrance onto the screen.
///
/// The [child] argument is the content of the dialog and must not be null.
class AnimatedDialog extends StatefulWidget {
  final Widget child;

  const AnimatedDialog({super.key, required this.child});

  @override
  AnimatedDialogState createState() => AnimatedDialogState();
}

class AnimatedDialogState extends State<AnimatedDialog> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    offset = Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero).animate(controller);

    // Start the animation.
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offset,
      child: AlertDialog(
        content: widget.child,
        backgroundColor: Theme.of(context).primaryColorLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            width: 3.0,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
