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
      String cptr = customer.findElements('cptr').first.value!;
      String acGuid = customer.findElements('AcGuid').first.value!;

      accCustomers.putIfAbsent(acGuid, () => []).add(cptr);
    }
    for (var acc in accountNodes) {
      String acName = acc.findElements('AccName').first.value!;
      String acGuid = acc.findElements('AccPtr').first.value!;
      accName[acGuid] = acName;
    }

    List<AccountModel> accFromLocal = accountNodes
        .where(
      (account) => account.getElement('AccName')?.value != '',
    )
        .map((account) {
      return AccountModel(
          id: account.getElement('AccPtr')?.value,
          accName: account.getElement('AccName')?.value,
          accLatinName: account.getElement('AccLatinName')?.value,
          accCode: account.getElement('AccCode')?.value,
          accCDate: dateFormat.tryParse(account.getElement('AccCDate')?.value ?? ''),
          accCheckDate: dateFormat.tryParse(account.getElement('AccCheckDate')?.value ?? ''),
          accParentGuid: account.getElement('AccParentGuid')?.value,
          accFinalGuid: account.getElement('AccFinalGuid')?.value,
          accAccNSons: int.parse(account.getElement('AccAccNSons')?.value ?? '0'),
          accInitDebit: double.parse(account.getElement('AccInitDebit')?.value ?? '0'),
          accInitCredit: double.parse(account.getElement('AccInitCredit')?.value ?? '0'),
          maxDebit: double.parse(account.getElement('MaxDebit')?.value ?? '0'),
          accWarn: double.parse(account.getElement('AccWarn')?.value.toString() ?? '0').toInt(),
          note: account.getElement('Note')?.value,
          accCurVal: int.parse(account.getElement('AccCurVal')?.value ?? '0'),
          accCurGuid: account.getElement('AccCurGuid')?.value,
          accSecurity: int.parse(account.getElement('AccSecurity')?.value ?? '0'),
          accDebitOrCredit: int.parse(account.getElement('AccDebitOrCredit')?.value ?? '0'),
          accType: int.parse(account.getElement('AccType')?.value ?? '0'),
          accState: int.parse(account.getElement('AccState')?.value ?? '0'),
          accIsChangableRatio: int.parse(account.getElement('AccIsChangableRatio')?.value ?? '0'),
          accBranchGuid: account.getElement('AccBranchGuid')?.value,
          accNumber: int.parse(account.getElement('AccNumber')?.value ?? '0'),
          accBranchMask: int.parse(account.getElement('AccBranchMask')?.value ?? '0'),
          accCustomer: accCustomers[account.getElement('AccPtr')?.value],
          accParentName: accName[account.getElement('AccParentGuid')?.value]);
    }).toList();

    return accFromLocal;
  }
}