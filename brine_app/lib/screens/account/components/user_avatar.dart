import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A widget that displays a user's avatar, either as a profile picture or as initials in a circular container.
class UserAvatar extends StatelessWidget {
  /// Creates an instance of [UserAvatar].
  const UserAvatar({required this.user, this.radius = 50.0, super.key});

  /// The user whose avatar should be displayed.
  final User? user;

  /// The radius of the avatar circle.
  final double radius;

  /// Generates initials from the user's display name.
  String get _userInitials {
    final String displayName = user?.displayName ?? user?.email ?? '';
    if (displayName.isEmpty) return '';

    final List<String> nameParts = displayName.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0].substring(0, 1).toUpperCase();
    }

    return '${nameParts.first.substring(0, 1)}${nameParts.last.substring(0, 1)}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // If the user has a profile picture, display it
        if (user?.photoURL != null) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(user!.photoURL!),
          );
        }

        // Otherwise, display the user's initials inside a circular avatar
        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF212121), // Always dark color on primary
              width: 2,
            ),
            color: Theme.of(context).primaryColor,
          ),
          child: Center(
            child: Text(
              _userInitials,

              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                color: const Color(0xFF212121), // Always dark color on primary
                fontFamily: GoogleFonts.bungee().fontFamily,
              ),
            ),
          ),
        );
      },
    );
  }
}
