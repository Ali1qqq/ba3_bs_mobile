import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_fromat_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/bond_model.dart';
import 'package:xml/xml.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';
import '../../data/models/pay_item_model.dart';

class BondImport extends ImportServiceBase<BondModel> with FirestoreSequentialNumbers {
  /// Converts the imported JSON structure to a list of BondModel
  @override
  List<BondModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> bondsJson = jsonContent['MainExp']['Export']['Pay']['P'] ?? [];
    return bondsJson.map((bondJson) => BondModel.fromImportedJsonFile(bondJson as Map<String, dynamic>)).toList();
  }

  Map<String, int> bondsNumbers = {for (var bondType in BondType.values) bondType.typeGuide: 0};

  Future<void> _initializeNumbers() async {
    bondsNumbers = {
      for (var billType in BondType.values)
        billType.typeGuide: await getLastNumber(
          category: ApiConstants.bonds,
          entityType: billType.label,
          // number: 0,
        )
    };
  }

  int getLastBondNumber(String billTypeGuid) {
    if (!bondsNumbers.containsKey(billTypeGuid)) {
      throw Exception('Bond type not found');
    }
    bondsNumbers[billTypeGuid] = bondsNumbers[billTypeGuid]! + 1;
    return bondsNumbers[billTypeGuid]!;
  }

  _setLastNumber() async {
    bondsNumbers.forEach(
      (billTypeGuid, number) async {
        await satNumber(ApiConstants.bonds, BondType.byTypeGuide(billTypeGuid).label, number);
      },
    );
  }

  @override
  Future<List<BondModel>> fromImportXml(XmlDocument document) async {
    await _initializeNumbers();

    final bondNodes = document.findAllElements('W');
    // final bondNodes = document.findAllElements('P');

    final accountWithName = document.findAllElements('A');

    Map<String, String> accNameWithId = {};

    for (var acc in accountWithName) {
      String accId = acc.findElements('AccPtr').first.value ?? '';
      String accName = acc.findElements('AccName').first.value ?? '';
      accNameWithId[accId] = accName;
    }

    List<BondModel> bonds = bondNodes.map((node) {
      final payItemsNode = node.getElement('PayItems');

      final payItemList = payItemsNode?.findAllElements('N').map((itemNode) {
            return PayItem(
              entryAccountName: accNameWithId[itemNode.getElement('EntryAccountGuid')?.value ?? ''],
              // read<AccountsController>().getAccountNameById(itemNode.getElement('EntryAccountGuid')?.value??''),
              // entryAccountGuid: itemNode.getElement('EntryAccountGuid')?.value??'',
              entryAccountGuid:
                  read<AccountsController>().getAccountIdByName(accNameWithId[itemNode.getElement('EntryAccountGuid')?.value ?? '']),
              entryDate: (itemNode.getElement('EntryDate')!.value ?? ''.toYearMonthDayFormat()),
              entryDebit: double.tryParse(itemNode.getElement('EntryDebit')?.value ?? '0'),
              entryCredit: double.tryParse(itemNode.getElement('EntryCredit')?.value ?? '0'),
              entryNote: itemNode.getElement('EntryNote')?.value ?? '',
              entryCurrencyGuid: itemNode.getElement('EntryCurrencyGuid')?.value ?? '',
              entryCurrencyVal: double.tryParse(itemNode.getElement('EntryCurrencyVal')?.value ?? '0'),
              entryCostGuid: itemNode.getElement('EntryCostGuid')?.value ?? '',
              entryClass: itemNode.getElement('EntryClass')?.value ?? '',
              entryNumber: int.tryParse(itemNode.getElement('EntryNumber')?.value ?? '0'),
              entryCustomerGuid: itemNode.getElement('EntryCustomerGuid')?.value ?? '',
              entryType: int.tryParse(itemNode.getElement('EntryType')?.value ?? '0'),
            );
          }).toList() ??
          [];

      // إنشاء كائن BondModel
      return BondModel(
        payTypeGuid: '2a550cb5-4e91-4e68-bacc-a0e7dcbbf1de',
        // payTypeGuid: node.getElement('PayTypeGuid')?.value??'',
        payNumber: getLastBondNumber('2a550cb5-4e91-4e68-bacc-a0e7dcbbf1de'),
        // payNumber: getLastBondNumber(node.getElement('PayTypeGuid')!.value??''),
        payGuid: node.getElement('CEntryGuid')?.value ?? '',
        // payGuid: node.getElement('PayGuid')?.value??'',
        payBranchGuid: node.getElement('CEntryBranch')?.value ?? '',
        // payBranchGuid: node.getElement('PayBranchGuid')?.value??'',
        payDate: node.getElement('CEntryDate')?.value ?? ''.toYearMonthDayFormat(),
        // payDate: node.getElement('PayDate')?.value??''.toYearMonthDayFormat(),
        entryPostDate: node.getElement('CEntryPostDate')?.value ?? '',
        // entryPostDate: node.getElement('EntryPostDate')?.value??'',
        payNote: node.getElement('CEntryNote')?.value ?? '',
        // payNote: node.getElement('PayNote')?.value??'',
        payCurrencyGuid: node.getElement('CEntryCurrencyGuid')?.value ?? '',
        // payCurrencyGuid: node.getElement('PayCurrencyGuid')?.value??'',
        payCurVal: double.tryParse((node.getElement('CEntryDebit')?.value ?? '').replaceAll(',', '')),
        // payCurVal: double.tryParse(node.getElement('PayCurVal')?.value??'' ?? '0'),
        // payAccountGuid: node.getElement('PayAccountGuid')?.value??'',
        payAccountGuid: '00000000-0000-0000-0000-000000000000',
        paySecurity: int.tryParse(node.getElement('CEntrySecurity')?.value ?? '0'),
        // paySecurity: int.tryParse(node.getElement('PaySecurity')?.value??'' ?? '0'),
        paySkip: 0,
        // paySkip: int.tryParse(node.getElement('PaySkip')?.value??'' ?? '0'),

        erParentType: 0,
        // erParentType: int.tryParse(node.getElement('ErParentType')?.value??'' ?? '0'),
        payItems: PayItems(itemList: payItemList),
        e: node.getElement('E')?.value ?? '',
      );
    }).toList();
    await _setLastNumber();
    return bonds;
  }
}
