import 'package:ba3_bs_mobile/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;
import '../../helper/enums/enums.dart';

/// A class responsible for exporting store account data into an XML format.
class StoresExport {
  /// Exports a list of StoreAccount objects as an XML element.
  ///
  /// This method creates an XML element with the tag 'Stores'. It starts by adding a child
  /// element 'StoresCount' that represents the total number of store accounts (formatted with two decimals).
  /// Then, it maps each store account to its corresponding XML element with the tag 'S',
  /// which contains various properties of the store.
  ///
  /// Parameters:
  /// - [stores]: A list of StoreAccount objects to be exported.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the exported stores.
  xml.XmlElement exportStores(List<StoreAccount> stores) {
    final storeElements = <xml.XmlNode>[
      // Create an XML element to display the count of stores.
      xml.XmlElement(
        xml.XmlName('StoresCount'),
        [],
        [xml.XmlText(stores.length.toStringAsFixed(2))],
      ),
      // Map each store account to its XML representation.
      ...stores.map((s) => xml.XmlElement(
            xml.XmlName('S'),
            [],
            [
              // Create an element for the store type guide.
              XmlHelpers.element('sptr', s.typeGuide),
              // Set StoreCode to '1' if the store is the main store; otherwise, '0'.
              XmlHelpers.element('StoreCode', s == StoreAccount.main ? '1' : '0'),
              // Create an element for the store name.
              XmlHelpers.element('StoreName', s.value),
              // Create an element for the store Latin name (currently set to null).
              XmlHelpers.element('StoreLatinName', null),
              // Create an element for the parent GUID with a default value.
              XmlHelpers.element('StoreParentGuid', '00000000-0000-0000-0000-000000000000'),
              // Create an element for the store account with a default value.
              XmlHelpers.element('StoreAcc', '00000000-0000-0000-0000-000000000000'),
              // Create an element for the store address (currently set to null).
              XmlHelpers.element('StoreAddress', null),
              // Create an element for the store keeper (currently set to null).
              XmlHelpers.element('StoreKeeper', null),
              // Create an element for the store branch mask with a default value.
              XmlHelpers.element('StoreBranchMask', '0'),
              // Create an element for the store security with a default value.
              XmlHelpers.element('StoreSecurity', '1'),
            ],
          )),
    ];

    // Return the root 'Stores' XML element containing all store elements.
    return xml.XmlElement(xml.XmlName('Stores'), [], storeElements);
  }
}