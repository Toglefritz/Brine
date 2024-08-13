/// An enumeration of distance units that can be used to measure the height of the water softener.
// ignore_for_file: public_member_api_docs
enum UnitOfMeasurement {
  inches('in'),
  feet('ft'),
  cm('cm'),
  mm('mm'),
  m('m');

  /// Creates an instance of [UnitOfMeasurement].
  const UnitOfMeasurement(this.label);

  /// The label for the unit of measurement.
  final String label;
}
