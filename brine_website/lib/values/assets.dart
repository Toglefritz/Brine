/// An enumeration of all the image assets used in the application.
enum Assets {
  brineLogo('brine_logo_large'),
  iphone13Mockup('iphone13_mockup');

  /// The file path for the image asset.
  final String _imagePath;

  /// Creates a new [Assets] instance with the given [_imagePath].
  const Assets(this._imagePath);

  /// Returns the [_imagePath] prefixed with the directory in which all image assets are stored.
  String get path {
    return 'assets/$_imagePath.png';
  }
}