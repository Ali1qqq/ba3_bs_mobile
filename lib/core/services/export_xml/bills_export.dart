import 'package:ba3_bs_mobile/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;
import '../../../features/bill/data/models/bill_model.dart';
import '../../helper/enums/enums.dart';

/// A class responsible for exporting bill data into an XML format.
class BillsExport {
  /// Generates the Bill section of the export XML.
  ///
  /// This method iterates over a list of [BillModel] objects and creates a list of XML elements.
  /// For each bill, it builds a 'Bill' element which contains:
  /// - A 'B' element with the main bill data,
  /// - An empty 'Disc' element (for discounts, if any),
  /// - An 'Items' element containing the bill items.
  ///
  /// Parameters:
  /// - [bills]: A list of [BillModel] objects to be exported.
  ///
  /// Returns:
  /// - A list of [xml.XmlElement] representing each bill.
  List<xml.XmlElement> exportBills(List<BillModel> bills) {
    return bills.map((bill) {
      return xml.XmlElement(
        xml.XmlName('Bill'),
        [],
        [
          _buildBillElement(bill), // Main bill data inside the <B> element.
          xml.XmlElement(xml.XmlName('Disc'), [], []), // Discount element (empty in this case).
          xml.XmlElement(xml.XmlName('Items'), [], _buildItems(bill)), // Bill items.
        ],
      );
    }).toList();
  }

  /// Builds the main bill element.
  ///
  /// This helper method converts a [BillModel] into an XML element with the tag 'B'.
  /// It maps various properties of the bill (e.g., type, guid, date, payment type, etc.) into individual XML elements.
  ///
  /// Parameters:
  /// - [bill]: A [BillModel] instance containing the bill details.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the main bill information.
  xml.XmlElement _buildBillElement(BillModel bill) {
    return xml.XmlElement(
      xml.XmlName('B'),
      [],
      [
        // Bill type identifier.
        XmlHelpers.element('BillTypeGuid', bill.billTypeModel.billTypeId),
        // Unique bill identifier.
        XmlHelpers.element('BillGuid', bill.billDetails.billGuid),
        // Bill branch (currently null).
        XmlHelpers.element('BillBranch', null),
        // Payment type, defaulting to '0' if null.
        XmlHelpers.element('BillPayType', bill.billDetails.billPayType?.toString() ?? '0'),
        // Check type GUID (currently null).
        XmlHelpers.element('BillCheckTypeGuid', null),
        // Bill number, defaulting to '0' if null.
        XmlHelpers.element('BillNumber', bill.billDetails.billNumber?.toString() ?? '0'),
        // Customer pointer.
        XmlHelpers.element('BillCustPtr', bill.billDetails.billCustomerId),
        // Customer name from the caches account.
        XmlHelpers.element('BillCustName', bill.billTypeModel.accounts?[BillAccounts.caches]?.accName),
        // Currency GUID with a default constant value.
        XmlHelpers.element('BillCurrencyGuid', '884edcde-c172-490d-a2f2-f10a0b90326a'),
        // Currency value (typically '1').
        XmlHelpers.element('BillCurrencyVal', '1'),
        // Bill date in ISO8601 format.
        XmlHelpers.element('BillDate', bill.billDetails.billDate?.toIso8601String()),
        // Store GUID from the store account.
        XmlHelpers.element('BillStoreGuid', bill.billTypeModel.accounts?[BillAccounts.store]?.id),
        // Bill note.
        XmlHelpers.element('Note', bill.billDetails.billNote),
        // Customer account GUID set to default.
        XmlHelpers.element('BillCustAcc', '00000000-0000-0000-0000-000000000000'),
        // Material account GUID (currently null).
        XmlHelpers.element('BillMatAccGuid', null),
        // Cost GUID set to default.
        XmlHelpers.element('BillCostGuid', '00000000-0000-0000-0000-000000000000'),
        // Vendor salesman details (default '0,0').
        XmlHelpers.element('BillVendorSalesMan', '0,0'),
        // First payment amount, defaulting to '0' if null.
        XmlHelpers.element('BillFirstPay', bill.billDetails.billFirstPay?.toString() ?? '0'),
        // First payment account GUID set to default.
        XmlHelpers.element('BillFPayAccGuid', '00000000-0000-0000-0000-000000000000'),
        // Security level for the bill.
        XmlHelpers.element('BillSecurity', '3'),
        // Transfer GUID set to default.
        XmlHelpers.element('BillTransferGuid', '00000000-0000-0000-0000-000000000000'),
        // Additional fields (currently null).
        XmlHelpers.element('BillFld1', null),
        XmlHelpers.element('BillFld2', null),
        XmlHelpers.element('BillFld3', null),
        XmlHelpers.element('BillFld4', null),
        // Items discount account (currently null).
        XmlHelpers.element('ItemsDiscAcc', null),
        // Items extra account GUID (currently null).
        XmlHelpers.element('ItemsExtraAccGUID', null),
        // Cost account GUID (currently null).
        XmlHelpers.element('CostAccGUID', null),
        // Stock account GUID (currently null).
        XmlHelpers.element('StockAccGUID', null),
        // Bonus account GUID (currently null).
        XmlHelpers.element('BonusAccGUID', null),
        // Bonus contra account GUID (currently null).
        XmlHelpers.element('BonusContraAccGUID', null),
        // VAT account GUID (currently null).
        XmlHelpers.element('VATAccGUID', null),
        // Discount card (currently null).
        XmlHelpers.element('DIscCard', null),
        // Bill address GUID set to default.
        XmlHelpers.element('BillAddressGUID', '00000000-0000-0000-0000-000000000000'),
      ],
    );
  }

  /// Builds the bill items.
  ///
  /// This helper method converts the list of items associated with a bill into XML elements.
  /// Each item is represented by an 'I' element with properties like item GUID, quantity,
  /// price details, store pointer, note, and other default values.
  ///
  /// Parameters:
  /// - [bill]: A [BillModel] instance containing the items.
  ///
  /// Returns:
  /// - A list of [xml.XmlElement] representing each item of the bill.
  List<xml.XmlElement> _buildItems(BillModel bill) {
    return bill.items.itemList.map((item) {
      // Build an item element with various item properties.
      return xml.XmlElement(
        xml.XmlName('I'),
        [],
        [
          // Material pointer (item unique identifier).
          XmlHelpers.element('MatPtr', item.itemGuid),
          // Quantity and bonus quantity, separated by a comma.
          XmlHelpers.element('QtyBonus', '${item.itemQuantity},${item.itemGiftsNumber ?? 0}'),
          // Unit, set to '1' by default.
          XmlHelpers.element('Unit', '1'),
          // Price description and extra details.
          XmlHelpers.element('PriceDescExtra', '${item.itemTotalPrice},0,0'),
          // Store pointer obtained from the bill's store account.
          XmlHelpers.element('StorePtr', bill.billTypeModel.accounts?[BillAccounts.store]?.id),
          // Item name as a note.
          XmlHelpers.element('Note', item.itemName),
          // Bonus discount (default '0').
          XmlHelpers.element('BonusDisc', '0'),
          // Quantity details repeated.
          XmlHelpers.element('UlQty', '${item.itemQuantity},${item.itemQuantity}'),
          // Cost pointer (currently null).
          XmlHelpers.element('CostPtr', null),
          // Class pointer (currently null).
          XmlHelpers.element('ClassPtr', null),
          // Class price (default '0').
          XmlHelpers.element('ClassPrice', '0'),
          // Expiry date for the product with a default value.
          XmlHelpers.element('ExpireProdDate', '1-1-1980,1-1-1980'),
          // Length, width, height, and an extra zero (default '0,0,0,0').
          XmlHelpers.element('LengthWidthHeight', '0,0,0,0'),
          // Item GUID (repeated here).
          XmlHelpers.element('Guid', item.itemGuid),
          // VAT ratio (default '0').
          XmlHelpers.element('VatRatio', '0'),
          // Sales order GUID (currently null).
          XmlHelpers.element('SoGuid', null),
          // Sales order type (default '0').
          XmlHelpers.element('SoType', '0'),
        ],
      );
    }).toList();
  }

  /// Exports a list of bill GUIDs as an XML element.
  ///
  /// This method filters out bills with non-null GUIDs and creates a 'BillGuids' element.
  /// Each bill GUID is wrapped inside a 'BillGuid' element.
  ///
  /// Parameters:
  /// - [bills]: A list of [BillModel] objects.
  ///
  /// Returns:
  /// - An [xml.XmlElement] containing the bill GUIDs.
  xml.XmlElement exportBillGuids(List<BillModel> bills) {
    return xml.XmlElement(
      xml.XmlName('BillGuids'),
      [],
      bills
          .where((b) => b.billDetails.billGuid != null)
          .map((b) => xml.XmlElement(
                xml.XmlName('BillGuid'),
                [],
                [xml.XmlText(b.billDetails.billGuid!)],
              ))
          .toList(),
    );
  }
}
/*  xml.XmlElement exportBills(List<BillModel> bills) {


    return xml.XmlElement(
      xml.XmlName('Bill'),
      [],
      bills.map((bill) => _buildBillElement(bill)).toList(),
    );
  }*/