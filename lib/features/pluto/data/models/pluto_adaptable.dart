import 'package:pluto_grid/pluto_grid.dart';

/// An interface for models that can be adapted for use in PlutoGrid.
///
/// Classes implementing this interface should provide a method to convert
/// their data into a format suitable for PlutoGrid representation.
abstract class PlutoAdaptable<T> {
  /// Converts the implementing model's data into a map format.
  ///
  /// Returns a [Map<String, dynamic>] representing the model's fields and their values.
  Map<PlutoColumn, dynamic> toPlutoGridFormat([T? type]);
}
