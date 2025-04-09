/// An enumeration of all the animated GIF assets used in the application.
// ignore_for_file: public_member_api_docs
enum Gifs {
  thanksFrog('frog_thanks.gif');

  /// The file path for the image asset.
  final String gifPath;

  /// Creates a new [Gifs] instance with the given [gifPath].
  const Gifs(this.gifPath);

  /// Returns the image path prefixed with the directory in which all image assets are stored.
  String get path {
    return 'assets/$gifPath';
  }
}
