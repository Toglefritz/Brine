import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/color_library.dart';
import '../../../../theme/insets.dart';
import '../../../../values/regex.dart';

/// A [TextFormField] without a border, underline, background, or other styling.
class BorderlessField extends StatelessWidget {
  /// Creates an [BorderlessField].
  ///
  /// The [BorderlessField] is intended to be used inside a [Form] widget. The [TextFormField] widget at the base of
  /// this composed widget uses a [TextEditingController] provided by the [controller] field. Validation of the
  /// [BorderlessField]'s value is performed by a function provided by the [validator] field. The [BorderlessField]
  /// uses an [InputDecoration] widget to style the field and provide useful information to the user. The hint
  /// text is provided by the [hint] field. The [BorderlessField] is designed without a border, underline, or fill
  /// color. When form validation returns an error, an suffix icon is displayed on the right side of the field. This
  /// behavior is set by the [errorState] boolean. When [errorState] is true, the icon is displayed. No icon is
  /// displayed when [errorState] is false. The text in the [BorderlessField] will be obscured if the
  /// [obscureText] boolean is true. The [additionalError] field provides text to display in an error state for errors
  /// returned by errors other than the [validator]. Typically, these errors result from actions performed after the
  /// surrounding [Form] is submitted.
  const BorderlessField({
    required this.hint,
    required this.controller,
    required this.validator,
    required this.errorState,
    super.key,
    this.obscureText,
    this.additionalError,
  });

  /// The hint text displayed in the [InputDecoration] widget.
  final String hint;

  /// Determines if the next in the field should be obscured.
  final bool? obscureText;

  /// A [TextEditingController] for the text input field.
  final TextEditingController controller;

  /// A function used to validate the [BorderlessField]'s entry when the surrounding [Form] is validated. Returns a
  /// string value if a validation error occurs, or null if validation is successful.
  final String? Function(String?) validator;

  /// Determines if a validation error was returned by the [validator].
  final bool errorState;

  /// An additional error to display outside of those returned by the [validator].
  final String? additionalError;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? false,
      inputFormatters: [FilteringTextInputFormatter(RegEx.authenticationFieldsCharset, allow: true)],
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(Insets.small),
        hintText: hint,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Theme.of(context).primaryColorDark.withOpacity(0.5),
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
        errorMaxLines: 3,
        errorStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColorDark,
        ),
        errorText: additionalError,
      ),
      cursorColor: Theme.of(context).primaryColorDark,
      cursorRadius: const Radius.circular(5),
      style: TextStyle(
        color: Theme.of(context).primaryColorDark,
      ),
      validator: validator,
    );
  }
}
