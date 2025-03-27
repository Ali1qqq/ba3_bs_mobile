import 'package:ba3_bs_mobile/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;
import '../../../features/cheques/data/models/cheques_model.dart';

/// A class responsible for exporting cheque (check) data into an XML format.
class ChequesExport {
  /// Generates the "Checks" section of the export XML.
  ///
  /// This method iterates over a list of [ChequesModel] objects and builds an XML element
  /// named 'Checks'. Each cheque is represented by an 'H' element containing its details.
  /// If a cheque is marked as paid (i.e. [ChequesModel.isPayed] is true), additional XML
  /// elements for the check collection entry and the check entry relation are included.
  ///
  /// Parameters:
  /// - [cheques]: A list of [ChequesModel] objects to be exported.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the exported checks.
  xml.XmlElement exportChecks(List<ChequesModel> cheques) {
    // Generate a unique GUID for the check entry collection.
    final cEntryGuid = XmlHelpers.uuid.v4();

    return xml.XmlElement(
      xml.XmlName('Checks'),
      [],
      cheques.map((chq) {
        return xml.XmlElement(
          xml.XmlName('H'),
          [],
          [
            // Cheque type GUID.
            XmlHelpers.element('CheckTypeGuid', chq.chequesTypeGuid),
            // Cheque number.
            XmlHelpers.element('CheckNumber', chq.chequesNumber?.toString()),
            // Secondary cheque number.
            XmlHelpers.element('CheckNum', chq.chequesNum?.toString()),
            // Parent GUID for the cheque (default value).
            XmlHelpers.element('CheckParentGuid', '00000000-0000-0000-0000-000000000000'),
            // Unique cheque GUID.
            XmlHelpers.element('CheckGuid', chq.chequesGuid),
            // Branch GUID for the cheque (default value).
            XmlHelpers.element('CheckBrGuid', '00000000-0000-0000-0000-000000000000'),
            // Cheque direction indicator (set to '2').
            XmlHelpers.element('CheckDir', '2'),
            // Account pointer associated with the cheque.
            XmlHelpers.element('AccPtr', chq.accPtr),
            // Cheque date.
            XmlHelpers.element('CheckDate', chq.chequesDate),
            // Cheque due date.
            XmlHelpers.element('CheckDueDate', chq.chequesDueDate),
            // Cheque collection date (default value).
            XmlHelpers.element('CheckColDate', '1-1-1980'),
            // Bank GUID for the cheque (default value).
            XmlHelpers.element('CheckBankGuid', '00000000-0000-0000-0000-000000000000'),
            // Cheque note.
            XmlHelpers.element('CheckNote', chq.chequesNote),
            // Cheque value (defaults to '0' if null).
            XmlHelpers.element('CheckVal', chq.chequesVal?.toString() ?? '0'),
            // Currency GUID for the cheque.
            XmlHelpers.element('CheckCurGuid', '884edcde-c172-490d-a2f2-f10a0b90326a'),
            // Currency value (typically '1').
            XmlHelpers.element('CheckCurVal', '1'),
            // Cheque security level (set to '1').
            XmlHelpers.element('CheckSec', '1'),
            // Previous cheque number (default '0').
            XmlHelpers.element('CheckPrevNum', '0'),
            // Original cheque organization name (null if not provided).
            XmlHelpers.element('CheckOrgName', null),
            // Internal cheque number (null if not provided).
            XmlHelpers.element('CheckIntNum', null),
            // Internal cheque file (null if not provided).
            XmlHelpers.element('CheckIntFile', null),
            // External cheque file (null if not provided).
            XmlHelpers.element('CheckExtFile', null),
            // Cheque file date, using the cheque date.
            XmlHelpers.element('CheckFileDate', chq.chequesDate),
            // First cost GUID for the cheque (default value).
            XmlHelpers.element('CheckCost1Guid', '00000000-0000-0000-0000-000000000000'),
            // Second cost GUID for the cheque (default value).
            XmlHelpers.element('CheckCost2Guid', '00000000-0000-0000-0000-000000000000'),
            // Secondary account GUID for the cheque.
            XmlHelpers.element('CheckAccount2Guid', chq.chequesAccount2Guid),
            // Cheque state: '1' if paid, '0' otherwise.
            XmlHelpers.element('CheckState', chq.isPayed == true ? '1' : '0'),
            // Cheque customer GUID (null by default; adjust if a value exists).
            XmlHelpers.element('CheckCustomerGuid', null),

            // If the cheque is marked as paid, include additional elements for collection and relation.
            if (chq.isPayed == true) ...[
              _buildCheckCollectEntry(chq, cEntryGuid),
              _buildCheckEntryRelation(chq, cEntryGuid),
            ],
          ],
        );
      }).toList(),
    );
  }

  /// Builds the check collection entry XML element for a paid cheque.
  ///
  /// This static helper method creates a 'CheckCollectEntry' element that contains an inner 'W'
  /// element with details about the cheque's collection entry, such as entry type, date, amounts,
  /// note, currency information, and branch details. It also includes a nested 'PayItems' element
  /// for potential payment item details.
  ///
  /// Parameters:
  /// - [chq]: The [ChequesModel] object representing the cheque.
  /// - [entryGuid]: A unique identifier for the payment entry.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the check collection entry.
  static xml.XmlElement _buildCheckCollectEntry(ChequesModel chq, String entryGuid) {
    return xml.XmlElement(
      xml.XmlName('CheckCollectEntry'),
      [],
      [
        xml.XmlElement(
          xml.XmlName('W'),
          [],
          [
            // Collection entry type (set to '1').
            XmlHelpers.element('CEntryType', '1'),
            // Collection entry type GUID (from the cheque type GUID).
            XmlHelpers.element('CEntryTypeGuid', chq.chequesTypeGuid),
            // Unique collection entry GUID.
            XmlHelpers.element('CEntryGuid', entryGuid),
            // Collection entry date (cheque payment date).
            XmlHelpers.element('CEntryDate', chq.chequesPayDate),
            // Collection entry posting date (same as payment date).
            XmlHelpers.element('CEntryPostDate', chq.chequesPayDate),
            // Debit amount for the collection entry.
            XmlHelpers.element('CEntryDebit', chq.chequesVal?.toString() ?? '0'),
            // Credit amount for the collection entry.
            XmlHelpers.element('CEntryCredit', chq.chequesVal?.toString() ?? '0'),
            // Note for the collection entry.
            XmlHelpers.element('CEntryNote', chq.chequesNote),
            // Currency GUID for the collection entry.
            XmlHelpers.element('CEntryCurrencyGuid', '884edcde-c172-490d-a2f2-f10a0b90326a'),
            // Currency value (typically '1').
            XmlHelpers.element('CEntryCurrencyVal', '1'),
            // Indicator that the entry is posted (set to '1').
            XmlHelpers.element('CEntryIsPosted', '1'),
            // Entry state (default '0').
            XmlHelpers.element('CEntryState', '0'),
            // Security level for the entry (set to '1').
            XmlHelpers.element('CEntrySecurity', '1'),
            // Branch GUID for the collection entry (default value).
            XmlHelpers.element('CEntryBranch', '00000000-0000-0000-0000-000000000000'),
            // Collection entry number (default '0').
            XmlHelpers.element('CEntryNumber', '0'),
            // Nested PayItems element for potential payment item details.
            xml.XmlElement(
              xml.XmlName('PayItems'),
              [],
              [
                xml.XmlElement(
                  xml.XmlName('N'),
                  [],
                  [
                    // Payment item account GUID.
                    XmlHelpers.element('EntryAccountGuid', chq.chequesAccount2Guid),
                    // Payment item date (cheque payment date).
                    XmlHelpers.element('EntryDate', chq.chequesPayDate),
                    // Payment item debit amount.
                    XmlHelpers.element('EntryDebit', chq.chequesVal?.toString() ?? '0'),
                    // Payment item credit amount (set to '0').
                    XmlHelpers.element('EntryCredit', '0'),
                    // Note for the payment item.
                    XmlHelpers.element('EntryNote', chq.chequesNote),
                    // Currency GUID for the payment item.
                    XmlHelpers.element('EntryCurrencyGuid', '884edcde-c172-490d-a2f2-f10a0b90326a'),
                    // Currency value (typically '1').
                    XmlHelpers.element('EntryCurrencyVal', '1'),
                    // Cost GUID for the payment item (default value).
                    XmlHelpers.element('EntryCostGuid', '00000000-0000-0000-0000-000000000000'),
                    // Class information for the payment item (derived from cheque number).
                    XmlHelpers.element('EntryClass', chq.chequesNum?.toString()),
                    // Payment item number (default '0').
                    XmlHelpers.element('EntryNumber', '0'),
                    // Customer GUID for the payment item (default value).
                    XmlHelpers.element('EntryCustomerGuid', '00000000-0000-0000-0000-000000000000'),
                    // Entry type (set to '0').
                    XmlHelpers.element('EntryType', '0'),
                  ],
                ),
              ],
            ),
          ],
        ),
        // An element representing the count of entries (set to '1.00').
        XmlHelpers.element('EntryCount', '1.00'),
      ],
    );
  }

  /// Builds the check entry relation XML element.
  ///
  /// This static helper method creates a 'CheckEntryRelation' element which defines the relationship
  /// between the cheque and its payment entry. It includes a nested 'Rel' element containing a unique
  /// relation GUID, the entry GUID, the cheque GUID, the parent type, and the cheque number.
  ///
  /// Parameters:
  /// - [chq]: The [ChequesModel] object representing the cheque.
  /// - [entryGuid]: The unique identifier used for the related payment entry.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the check entry relation.
  static xml.XmlElement _buildCheckEntryRelation(ChequesModel chq, String entryGuid) {
    // Generate a unique GUID for the entry relation.
    final erGuid = XmlHelpers.uuid.v4();

    return xml.XmlElement(
      xml.XmlName('CheckEntryRelation'),
      [],
      [
        xml.XmlElement(
          xml.XmlName('Rel'),
          [],
          [
            // Unique relation GUID.
            XmlHelpers.element('ErGUID', erGuid),
            // The payment entry GUID.
            XmlHelpers.element('ErEntryGUID', entryGuid),
            // The parent cheque GUID.
            XmlHelpers.element('ErParentGUID', chq.chequesGuid),
            // Parent type (set to '6').
            XmlHelpers.element('ErParentType', '6'),
            // Cheque number (defaults to '1' if null).
            XmlHelpers.element('ErParentNumber', chq.chequesNumber?.toString() ?? '1'),
          ],
        ),
      ],
    );
  }
}