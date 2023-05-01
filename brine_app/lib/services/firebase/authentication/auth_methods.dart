/// Represents methods that can be used to sign up (create an account) or log into the app.
enum AuthMethods {
  basicAuth('basicAuth'),
  phone('phone'),
  anonymous('anonymous'),
  google('google'),
  microsoft('microsoft'),
  facebook('facebook'),
  apple('apple'),
  gitHub('gitHub');

  /// A string identifier for the signup method
  final String identifier;

  const AuthMethods(this.identifier);
}
