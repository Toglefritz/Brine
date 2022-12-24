import 'package:brine/models/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';

///
class OnboardingField extends StatelessWidget {
  const OnboardingField({
    Key? key,
    required this.hint,
    this.obscureText,
  }) : super(key: key);

  final String hint;
  final bool? obscureText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: TextFormField(
        obscureText: obscureText ?? false,
        decoration: InputDecoration(
          filled: true,
          fillColor: ColorLibrary.primaryLight,
          contentPadding: const EdgeInsets.all(Insets.small),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              width: 3.0,
              color: ColorLibrary.primaryDefault,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              width: 3.0,
              color: ColorLibrary.primaryDefault,
            ),
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: ColorLibrary.primaryDefault.withOpacity(0.5),
          ),
        ),
        cursorColor: ColorLibrary.primaryDefault,
        cursorRadius: const Radius.circular(5.0),
        style: const TextStyle(
          color: ColorLibrary.primaryDefault,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a username (email)';
          }
          return null;
        },
      ),
    );
  }
}
