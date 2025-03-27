import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/date_format_extension.dart';
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
        await setLastUsedNumber(ApiConstants.bonds, BondType.byTypeGuide(billTypeGuid).label, number);
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
      String accId = acc.findElements('AccPtr').first.text;
      String accName = acc.findElements('AccName').first.text;
      accNameWithId[accId] = accName;
    }

    List<BondModel> bonds = bondNodes.map((node) {
      final payItemsNode = node.getElement('PayItems');

      final payItemList = payItemsNode?.findAllElements('N').map((itemNode) {
            return PayItem(
              entryAccountName: accNameWithId[itemNode.getElement('EntryAccountGuid')?.text],
              // read<AccountsController>().getAccountNameById(itemNode.getElement('EntryAccountGuid')?.text),
              // entryAccountGuid: itemNode.getElement('EntryAccountGuid')?.text,
              entryAccountGuid: read<AccountsController>().getAccountIdByName(accNameWithId[itemNode.getElement('EntryAccountGuid')?.text]),
              entryDate: (itemNode.getElement('EntryDate')!.text.toYearMonthDayFormat()),
              entryDebit: double.tryParse(itemNode.getElement('EntryDebit')?.text ?? '0'),
              entryCredit: double.tryParse(itemNode.getElement('EntryCredit')?.text ?? '0'),
              entryNote: itemNode.getElement('EntryNote')?.text,
              entryCurrencyGuid: itemNode.getElement('EntryCurrencyGuid')?.text,
              entryCurrencyVal: double.tryParse(itemNode.getElement('EntryCurrencyVal')?.text ?? '0'),
              entryCostGuid: itemNode.getElement('EntryCostGuid')?.text,
              entryClass: itemNode.getElement('EntryClass')?.text,
              entryNumber: int.tryParse(itemNode.getElement('EntryNumber')?.text ?? '0'),
              entryCustomerGuid: itemNode.getElement('EntryCustomerGuid')?.text,
              entryType: int.tryParse(itemNode.getElement('EntryType')?.text ?? '0'),
            );
          }).toList() ??
          [];

      // إنشاء كائن BondModel
      return BondModel(
        payTypeGuid: '2a550cb5-4e91-4e68-bacc-a0e7dcbbf1de',
        // payTypeGuid: node.getElement('PayTypeGuid')?.text,
        payNumber: getLastBondNumber('2a550cb5-4e91-4e68-bacc-a0e7dcbbf1de'),
        // payNumber: getLastBondNumber(node.getElement('PayTypeGuid')!.text),
        payGuid: node.getElement('CEntryGuid')?.text,
        // payGuid: node.getElement('PayGuid')?.text,
        payBranchGuid: node.getElement('CEntryBranch')?.text,
        // payBranchGuid: node.getElement('PayBranchGuid')?.text,
        payDate: node.getElement('CEntryDate')?.text.toYearMonthDayFormat(),
        // payDate: node.getElement('PayDate')?.text.toYearMonthDayFormat(),
        entryPostDate: node.getElement('CEntryPostDate')?.text,
        // entryPostDate: node.getElement('EntryPostDate')?.text,
        payNote: node.getElement('CEntryNote')?.text,
        // payNote: node.getElement('PayNote')?.text,
        payCurrencyGuid: node.getElement('CEntryCurrencyGuid')?.text,
        // payCurrencyGuid: node.getElement('PayCurrencyGuid')?.text,
        payCurVal: double.tryParse((node.getElement('CEntryDebit')?.text)!.replaceAll(',', '')),
        // payCurVal: double.tryParse(node.getElement('PayCurVal')?.text ?? '0'),
        // payAccountGuid: node.getElement('PayAccountGuid')?.text,
        payAccountGuid: '00000000-0000-0000-0000-000000000000',
        paySecurity: int.tryParse(node.getElement('CEntrySecurity')?.text ?? '0'),
        // paySecurity: int.tryParse(node.getElement('PaySecurity')?.text ?? '0'),
        paySkip: 0,
        // paySkip: int.tryParse(node.getElement('PaySkip')?.text ?? '0'),

        erParentType: 0,
        // erParentType: int.tryParse(node.getElement('ErParentType')?.text ?? '0'),
        payItems: PayItems(itemList: payItemList),
        e: node.getElement('E')?.text,
      );
    }).toList();
    await _setLastNumber();
    return bonds;
  }
}