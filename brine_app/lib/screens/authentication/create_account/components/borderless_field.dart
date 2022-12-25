import 'package:brine/models/insets.dart';
import 'package:brine/theme/color_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../values/regex.dart';

/// A [TextFormField] without a border, underline, background, or other styling.
class BorderlessField extends StatelessWidget {
  const BorderlessField({
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
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? false,
      inputFormatters: [FilteringTextInputFormatter(RegEx.alphanumeric, allow: true)],
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(Insets.small),
        hintText: hint,
        border: InputBorder.none,
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
    );
  }
}
