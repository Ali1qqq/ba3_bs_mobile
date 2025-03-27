import 'package:ba3_bs_mobile/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;
import '../../../features/sellers/data/models/seller_model.dart';

/// A class that exports seller data from seller models into an XML format.
class CostsExport {
  /// Exports a list of SellerModel objects as an XML element.
  ///
  /// This method constructs an XML element with the tag 'Cost1' that represents seller information.
  /// It begins by creating a child element 'CostCount' which displays the total number of seller entries
  /// (formatted with two decimals). Then, each SellerModel is converted into an XML element with the tag 'Q',
  /// containing various seller-related properties.
  ///
  /// Parameters:
  /// - [sellers]: A list of SellerModel objects containing seller data.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the exported seller data.
  xml.XmlElement exportCosts(List<SellerModel> sellers) {
    final costElements = <xml.XmlNode>[
      // Create an element to display the total count of seller entries.
      xml.XmlElement(
        xml.XmlName('CostCount'),
        [],
        [xml.XmlText(sellers.length.toStringAsFixed(2))],
      ),
      // Map each seller model to its XML representation.
      ...sellers.map((s) => xml.XmlElement(
            xml.XmlName('Q'),
            [],
            [
              // Unique identifier for the seller entry.
              XmlHelpers.element('CostGuid', s.costGuid),
              // Cost code converted to string if available.
              XmlHelpers.element('CostCode', s.costCode?.toString()),
              // Name of the seller.
              XmlHelpers.element('CostName', s.costName),
              // Latin name representation of the seller.
              XmlHelpers.element('CostLatinName', s.costLatinName),
              // Parent GUID for the seller; defaults to a standard value if null.
              XmlHelpers.element('CostParentGuid', s.costParentGuid ?? '00000000-0000-0000-0000-000000000000'),
              // Notes associated with the seller.
              XmlHelpers.element('CostNote', s.costNote),
              // Debit amount; defaults to '0.00' if null.
              XmlHelpers.element('CostDebit', s.costDebit ?? '0.00'),
              // Credit amount; defaults to '0.00' if null.
              XmlHelpers.element('CostCredit', s.costCredit ?? '0.00'),
              // Cost type formatted to two decimal places; defaults to '0.00' if null.
              XmlHelpers.element('CostType', s.costType?.toStringAsFixed(2) ?? '0.00'),
              // Security level formatted to two decimal places; defaults to '1.00' if null.
              XmlHelpers.element('CostSecurity', s.costSecurity?.toStringAsFixed(2) ?? '1.00'),
              // First resource value formatted to two decimals; defaults to '0.00' if null.
              XmlHelpers.element('CostRes1', s.costRes1?.toStringAsFixed(2) ?? '0.00'),
              // Second resource value formatted to two decimals; defaults to '0.00' if null.
              XmlHelpers.element('CostRes2', s.costRes2?.toStringAsFixed(2) ?? '0.00'),
              // Branch mask for the seller; defaults to '0' if null.
              XmlHelpers.element('CostBranchMask', s.costBranchMask?.toString() ?? '0'),
              // Indicates whether the seller ratio is changeable, formatted to two decimals; defaults to '0.00' if null.
              XmlHelpers.element('CostIsChangeableRatio', s.costIsChangeableRatio?.toStringAsFixed(2) ?? '0.00'),
            ],
          )),
    ];

    // Return the root 'Cost1' XML element that encapsulates all seller elements.
    return xml.XmlElement(xml.XmlName('Cost1'), [], costElements);
  }
}