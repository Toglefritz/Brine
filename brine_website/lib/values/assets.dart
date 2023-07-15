/// An enumeration of all the image assets used in the application.
enum Asset {
  brineLogo('brine_logo_large'),
  hair('hair'),
  iphone13Mockup('iphone13_mockup'),
  numeral1('numeral_1'),
  numeral2('numeral_2'),
  numeral3('numeral_3'),
  partsDiagram('brine_parts_map'),
  soapHands('soap_hands'),
  socks('socks'),
  waterMinerals('water_minerals_icon');

  /// The file path for the image asset.
  final String _imagePath;

  /// Creates a new [Asset] instance with the given [_imagePath].
  const Asset(this._imagePath);

  /// Returns the [_imagePath] prefixed with the directory in which all image assets are stored.
  String get path {
    return 'assets/$_imagePath.png';
  }
}
