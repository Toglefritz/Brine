/// Provides regular expressions used throughout the app.
class RegEx {
  /// Matches characters that are acceptable in the authentication-related text input fields.
  static RegExp authenticationFieldsCharset =
      RegExp('^[ A-Za-z0-9_@!#\$%&\'*+-/=?^_`{|}~]*');

  /// Matches valid email address according to the HTML5 spec:m https://html.spec.whatwg.org/multipage/input.html#e-mail-state-%28type=email%29
  static RegExp emailAddress = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
  );
}
