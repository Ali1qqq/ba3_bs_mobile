import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';

class AccountImport extends ImportServiceBase<AccountModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<AccountModel> fromImportJson(Map<String, dynamic> jsonContent) {
    return [];
  }

  @override
  Future<List<AccountModel>> fromImportXml(XmlDocument document) async {
    final accountNodes = document.findAllElements('A');
    final customers = document.findAllElements('Cu');
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');

    Map<String, List<String>> accCustomers = {};
    Map<String, String> accName = {};

    for (var customer in customers) {
      String cptr = customer.findElements('cptr').first.text;
      String acGuid = customer.findElements('AcGuid').first.text;

      accCustomers.putIfAbsent(acGuid, () => []).add(cptr);
    }
    for (var acc in accountNodes) {
      String acName = acc.findElements('AccName').first.text;
      String acGuid = acc.findElements('AccPtr').first.text;
      accName[acGuid] = acName;
    }

    List<AccountModel> accFromLocal = accountNodes
        .where(
      (account) => account.getElement('AccName')?.text != '',
    )
        .map((account) {
      return AccountModel(
          id: account.getElement('AccPtr')?.text,
          accName: account.getElement('AccName')?.text,
          accLatinName: account.getElement('AccLatinName')?.text,
          accCode: account.getElement('AccCode')?.text,
          accCDate: dateFormat.tryParse(account.getElement('AccCDate')?.text ?? ''),
          accCheckDate: dateFormat.tryParse(account.getElement('AccCheckDate')?.text ?? ''),
          accParentGuid: account.getElement('AccParentGuid')?.text,
          accFinalGuid: account.getElement('AccFinalGuid')?.text,
          accAccNSons: int.parse(account.getElement('AccAccNSons')?.text ?? '0'),
          accInitDebit: double.parse(account.getElement('AccInitDebit')?.text ?? '0'),
          accInitCredit: double.parse(account.getElement('AccInitCredit')?.text ?? '0'),
          maxDebit: double.parse(account.getElement('MaxDebit')?.text ?? '0'),
          accWarn: double.parse(account.getElement('AccWarn')?.text.toString() ?? '0').toInt(),
          note: account.getElement('Note')?.text,
          accCurVal: int.parse(account.getElement('AccCurVal')?.text ?? '0'),
          accCurGuid: account.getElement('AccCurGuid')?.text,
          accSecurity: int.parse(account.getElement('AccSecurity')?.text ?? '0'),
          accDebitOrCredit: int.parse(account.getElement('AccDebitOrCredit')?.text ?? '0'),
          accType: int.parse(account.getElement('AccType')?.text ?? '0'),
          accState: int.parse(account.getElement('AccState')?.text ?? '0'),
          accIsChangableRatio: int.parse(account.getElement('AccIsChangableRatio')?.text ?? '0'),
          accBranchGuid: account.getElement('AccBranchGuid')?.text,
          accNumber: int.parse(account.getElement('AccNumber')?.text ?? '0'),
          accBranchMask: int.parse(account.getElement('AccBranchMask')?.text ?? '0'),
          accCustomer: accCustomers[account.getElement('AccPtr')?.text],
          accParentName: accName[account.getElement('AccParentGuid')?.text]);
    }).toList();

    return accFromLocal;
  }
}