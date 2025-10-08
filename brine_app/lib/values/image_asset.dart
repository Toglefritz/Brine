/// Provides image assets used throughout the app.
// ignore_for_file: public_member_api_docs
enum ImageAsset {
  apple('apple.png'),
  bluetoothError('bluetooth_error.png'),
  error('error.png'),
  google('google.png'),
  logoTransparentBackground('icons/brine_transparent_background.png'),
  logoTransparentBackgroundInverse(
    'icons/brine_transparent_background_inverse.png',
  ),
  waterSoftener('water_softener_outline.png');

  const ImageAsset(this.relativePath);

  /// The path to the image asset, relative to the [_pathPrefix].
  final String relativePath;

  /// The base path for all image assets.
  final String _pathPrefix = 'assets/';

  /// Returns the full path to the image asset.
  String get path => '$_pathPrefix$relativePath';
}
