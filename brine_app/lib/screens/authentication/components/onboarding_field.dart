import 'package:brine/models/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:brine/values/regex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A bordered text input field.
class OnboardingField extends StatelessWidget {
  const OnboardingField({
    Key? key,
    required this.hint,
    this.obscureText,
    required this.controller,
    required this.validator,
    required this.errorState,
  }) : super(key: key);

  final String hint;
  final bool? obscureText;
  final TextEditingController controller;
  final Function(String?) validator;
  final bool errorState;

  @override
  Widget build(BuildContext context) {
    /// The default border used for all states of the [OnboardingField].
    OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(
        width: 3.0,
        color: ColorLibrary.primaryDefault,
      ),
    );

    return SizedBox(
      width: 350,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText ?? false,
        inputFormatters: [FilteringTextInputFormatter(RegEx.alphanumeric, allow: true)],
        decoration: InputDecoration(
          filled: true,
          fillColor: ColorLibrary.primaryLight,
          contentPadding: const EdgeInsets.all(Insets.small),
          enabledBorder: defaultBorder,
          focusedBorder: defaultBorder,
          errorBorder: defaultBorder,
          focusedErrorBorder: defaultBorder,
          disabledBorder: defaultBorder,
          border: defaultBorder,
          hintText: hint,
          hintStyle: TextStyle(
            color: ColorLibrary.primaryDefault.withOpacity(0.5),
          ),
          suffixIcon: errorState
              ? GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.only(
                      right: Insets.small,
                    ),
                    child: Icon(
                      Icons.error_outline_outlined,
                      color: ColorLibrary.error,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          errorMaxLines: 2,
          errorStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        cursorColor: ColorLibrary.primaryDefault,
        cursorRadius: const Radius.circular(5.0),
        style: const TextStyle(
          color: ColorLibrary.primaryDefault,
        ),
        validator: (value) => validator(value),
      ),
    );
  }
}
