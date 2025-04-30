import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart' as xml;

/// A helper class that provides utility methods for XML operations
/// such as creating XML elements and calculating VAT ratios.
class XmlHelpers {
  /// A static instance of [Uuid] to generate unique identifiers.
  static final uuid = Uuid();

  /// Builds an XML element with the given [name] and [value].
  ///
  /// This instance method returns an XML element. If the [value] is either
  /// null or empty, it returns an empty element with no child nodes; otherwise,
  /// it returns an element containing a text node with the provided [value].
  ///
  /// Parameters:
  /// - [name]: The name of the XML element.
  /// - [value]: The text value for the XML element.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the constructed XML element.
  xml.XmlElement buildElement(String name, String? value) {
    return value == null || value.isEmpty
        ? xml.XmlElement(xml.XmlName(name), [], [])
        : xml.XmlElement(xml.XmlName(name), [], [xml.XmlText(value)]);
  }

  /// A static method to create an XML element with the specified [name] and [value].
  ///
  /// If the [value] is null, the method returns an empty XML element without any child nodes.
  /// Otherwise, it creates an element containing a text node with the provided [value].
  ///
  /// Parameters:
  /// - [name]: The name of the XML element.
  /// - [value]: The text content to include in the XML element.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the created element.
  static xml.XmlElement element(String name, String? value) {
    return value == null
        ? xml.XmlElement(xml.XmlName(name), [], [])
        : xml.XmlElement(xml.XmlName(name), [], [xml.XmlText(value)]);
  }

  /// Calculates the VAT ratio as a percentage based on the provided [vat] and [subtotal].
  ///
  /// If either [vat] or [subtotal] is null or zero, the function returns 0.
  /// Otherwise, it computes the ratio (vat / subtotal) multiplied by 100 and rounds the result
  /// to the nearest integer.
  ///
  /// Parameters:
  /// - [vat]: The VAT amount.
  /// - [subtotal]: The subtotal amount.
  ///
  /// Returns:
  /// - An [int] representing the calculated VAT ratio percentage.
  static int calcVatRatio(double? vat, double? subtotal) {
    if (vat == null || vat == 0 || subtotal == null || subtotal == 0) return 0;
    return ((vat / subtotal) * 100).round();
  }
}
