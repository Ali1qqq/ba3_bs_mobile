import 'package:ba3_bs_mobile/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;
import '../../../features/accounts/data/models/account_model.dart';

/// A class that handles exporting account data into XML format.
class AccountsExport {
  /// Exports a list of AccountModel objects as an XML element.
  ///
  /// This method creates an XML element with the tag 'Accounts'. It first adds a child element
  /// 'AccountsCount' that displays the number of accounts (formatted with two decimals). Then,
  /// it maps each account to its corresponding XML element by calling [_buildAccountElement].
  ///
  /// Parameters:
  /// - [accounts]: A list of AccountModel objects to be exported.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the exported accounts.
  xml.XmlElement exportAccounts(List<AccountModel> accounts) {
    final accountElements = <xml.XmlNode>[
      // Creates an element to show the total count of accounts.
      xml.XmlElement(
        xml.XmlName('AccountsCount'),
        [],
        [xml.XmlText(accounts.length.toStringAsFixed(2))],
      ),
      // Converts each AccountModel to its XML representation.
      ...accounts.map((acc) => _buildAccountElement(acc)),
    ];

    // Returns the root 'Accounts' XML element containing all account elements.
    return xml.XmlElement(xml.XmlName('Accounts'), [], accountElements);
  }

  /// Builds an XML element for a single account.
  ///
  /// This helper method converts an [AccountModel] object into an XML element with the tag 'A'.
  /// It uses the [XmlHelpers.element] method to create child elements for each property of the account.
  ///
  /// Parameters:
  /// - [acc]: An instance of AccountModel containing account data.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the account.
  xml.XmlElement _buildAccountElement(AccountModel acc) {
    return xml.XmlElement(
      xml.XmlName('A'),
      [],
      [
        XmlHelpers.element('AccPtr', acc.id),
        XmlHelpers.element('AccName', acc.accName),
        XmlHelpers.element('AccLatinName', acc.accLatinName),
        XmlHelpers.element('AccCode', acc.accCode),
        // Formats the account creation date to ISO8601 format and extracts only the date part.
        XmlHelpers.element('AccCDate', acc.accCDate?.toIso8601String().split('T').first),
        // Formats the account check date similarly.
        XmlHelpers.element('AccCheckDate', acc.accCheckDate?.toIso8601String().split('T').first),
        XmlHelpers.element('AccParentGuid', acc.accParentGuid),
        XmlHelpers.element('AccFinalGuid', acc.accFinalGuid),
        XmlHelpers.element('AccAccNSons', acc.accAccNSons?.toString()),
        // Sets a default value of '0.00' if the initial debit is null.
        XmlHelpers.element('AccInitDebit', acc.accInitDebit?.toString() ?? '0.00'),
        // Sets a default value of '0.00' if the initial credit is null.
        XmlHelpers.element('AccInitCredit', acc.accInitCredit?.toString() ?? '0.00'),
        // Sets a default value of '0.00' if the max debit is null.
        XmlHelpers.element('MaxDebit', acc.maxDebit?.toString() ?? '0.00'),
        // Sets a default value of '0.00' if the warning amount is null.
        XmlHelpers.element('AccWarn', acc.accWarn?.toString() ?? '0.00'),
        XmlHelpers.element('Note', acc.note),
        // Sets a default value of '1' if the current value is null.
        XmlHelpers.element('AccCurVal', acc.accCurVal?.toString() ?? '1'),
        XmlHelpers.element('AccCurGuid', acc.accCurGuid ?? '884edcde-c172-490d-a2f2-f10a0b90326a'),
        // Sets a default value of '1' if the security level is null.
        XmlHelpers.element('AccSecurity', acc.accSecurity?.toString() ?? '1'),
        // Sets a default value of '0' if the debit or credit flag is null.
        XmlHelpers.element('AccDebitOrCredit', acc.accDebitOrCredit?.toString() ?? '0'),
        // Sets a default value of '1' if the account type is null.
        XmlHelpers.element('AccType', acc.accType?.toString() ?? '1'),
        // Sets a default value of '0' if the account state is null.
        XmlHelpers.element('AccState', acc.accState?.toString() ?? '0'),
        // Sets a default value of '0' if the changeable ratio flag is null.
        XmlHelpers.element('AccIsChangableRatio', acc.accIsChangableRatio?.toString() ?? '0'),
        // Provides a default branch GUID if none is supplied.
        XmlHelpers.element('AccBranchGuid', acc.accBranchGuid ?? '00000000-0000-0000-0000-000000000000'),
        XmlHelpers.element('AccNumber', acc.accNumber?.toString()),
        // Sets a default value of '0' if the branch mask is null.
        XmlHelpers.element('AccBranchMask', acc.accBranchMask?.toString() ?? '0'),
      ],
    );
  }
}