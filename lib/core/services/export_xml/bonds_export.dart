import 'package:ba3_bs_mobile/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;
import '../../../features/bond/data/models/bond_model.dart';

/// A class responsible for exporting bond (or payment) data into an XML format.
class BondsExport {
  /// Exports a list of BondModel objects as an XML element.
  ///
  /// This method creates an XML element with the tag 'Pay'. It starts by adding a child element
  /// 'PayCount' that represents the total number of bond entries (formatted with two decimals). Then,
  /// it maps each bond to its corresponding XML element using [_buildBondElement].
  ///
  /// Parameters:
  /// - [bonds]: A list of [BondModel] objects to be exported.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the exported bonds.
  xml.XmlElement exportBonds(List<BondModel> bonds) {
    final accountElements = <xml.XmlNode>[
      // Element showing the count of bond entries.
      xml.XmlElement(
        xml.XmlName('PayCount'),
        [],
        [xml.XmlText(bonds.length.toStringAsFixed(2))],
      ),
      // Map each bond to its XML representation.
      ...bonds.map((bond) => _buildBondElement(bond)),
    ];

    // Returns the root 'Pay' element that encapsulates all bond elements.
    return xml.XmlElement(xml.XmlName('Pay'), [], accountElements);
  }

  /// Builds an XML element for a single bond.
  ///
  /// This helper method converts a [BondModel] into an XML element with the tag 'P' which represents
  /// a payment entry. It constructs the element with various properties of the bond and its associated
  /// pay items. The pay items are built as a list of 'N' elements using the [_buildBondElement] mapping.
  ///
  /// Parameters:
  /// - [bond]: A [BondModel] instance containing bond data.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the bond.
  xml.XmlElement _buildBondElement(BondModel bond) {
    // Map each pay item to its XML representation.
    final items = bond.payItems.itemList.map((item) {
      return xml.XmlElement(
        xml.XmlName('N'),
        [],
        [
          // Account GUID for the entry.
          XmlHelpers.element('EntryAccountGuid', item.entryAccountGuid),
          // Entry date.
          XmlHelpers.element('EntryDate', item.entryDate),
          // Debit amount (defaults to '0' if null).
          XmlHelpers.element('EntryDebit', item.entryDebit?.toString() ?? '0'),
          // Credit amount (defaults to '0' if null).
          XmlHelpers.element('EntryCredit', item.entryCredit?.toString() ?? '0'),
          // Note for the entry.
          XmlHelpers.element('EntryNote', item.entryNote),
          // Currency GUID for the entry.
          XmlHelpers.element('EntryCurrencyGuid', item.entryCurrencyGuid),
          // Currency value (defaults to '1' if null).
          XmlHelpers.element('EntryCurrencyVal', item.entryCurrencyVal?.toString() ?? '1'),
          // Cost GUID for the entry.
          XmlHelpers.element('EntryCostGuid', item.entryCostGuid),
          // Class information for the entry.
          XmlHelpers.element('EntryClass', item.entryClass),
          // Entry number (defaults to '0' if null).
          XmlHelpers.element('EntryNumber', item.entryNumber?.toString() ?? '0'),
          // Customer GUID for the entry.
          XmlHelpers.element('EntryCustomerGuid', item.entryCustomerGuid),
          // Entry type (defaults to '0' if null).
          XmlHelpers.element('EntryType', item.entryType?.toString() ?? '0'),
        ],
      );
    }).toList();

    // Build and return the main bond (payment) element.
    return xml.XmlElement(
      xml.XmlName('P'),
      [],
      [
        // Payment type GUID.
        XmlHelpers.element('PayTypeGuid', bond.payTypeGuid),
        // Payment number (defaults to '0' if null).
        XmlHelpers.element('PayNumber', bond.payNumber?.toString() ?? '0'),
        // Unique payment GUID.
        XmlHelpers.element('PayGuid', bond.payGuid),
        // Payment branch GUID.
        XmlHelpers.element('PayBranchGuid', bond.payBranchGuid),
        // Payment date.
        XmlHelpers.element('PayDate', bond.payDate),
        // Posting date for the payment entry.
        XmlHelpers.element('EntryPostDate', bond.entryPostDate),
        // Payment note.
        XmlHelpers.element('PayNote', bond.payNote),
        // Payment currency GUID.
        XmlHelpers.element('PayCurrencyGuid', bond.payCurrencyGuid),
        // Payment currency value (defaults to '1' if null).
        XmlHelpers.element('PayCurVal', bond.payCurVal?.toString() ?? '1'),
        // Payment account GUID.
        XmlHelpers.element('PayAccountGuid', bond.payAccountGuid),
        // Payment security level (defaults to '1' if null).
        XmlHelpers.element('PaySecurity', bond.paySecurity?.toString() ?? '1'),
        // Payment skip flag (defaults to '0' if null).
        XmlHelpers.element('PaySkip', bond.paySkip?.toString() ?? '0'),
        // Parent type for the entry (defaults to '4' if null).
        XmlHelpers.element('ErParentType', bond.erParentType?.toString() ?? '4'),
        // Build the pay items section containing all 'N' elements.
        xml.XmlElement(xml.XmlName('PayItems'), [], items),
        // An extra element 'E' with a default value of 'E=2' if null.
        XmlHelpers.element('E', bond.e ?? 'E=2'),
      ],
    );
  }
}