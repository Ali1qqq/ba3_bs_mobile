import 'package:ba3_bs_mobile/features/bond/data/models/bond_model.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';
import '../../data/models/pay_item_model.dart';

class BondImport extends ImportServiceBase<BondModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<BondModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> billsJson = jsonContent['MainExp']['Export']['Pay']['P'] ?? [];
    return billsJson.map((bondJson) => BondModel.fromImportedJsonFile(bondJson as Map<String, dynamic>)).toList();
  }

  @override
  List<BondModel> fromImportXml(XmlDocument document) {
    // العثور على جميع العقد <P> داخل <Pay>
    final bondNodes = document.findAllElements('P');

    return bondNodes.map((node) {
      // تحليل العناصر الرئيسية لـ BondModel
      final payItemsNode = node.getElement('PayItems');

      // إنشاء قائمة من PayItem
      final payItemList = payItemsNode?.findAllElements('N').map((itemNode) {
            return PayItem(
              entryAccountGuid: itemNode.getElement('EntryAccountGuid')?.value,
              entryDate: itemNode.getElement('EntryDate')?.value,
              entryDebit: double.tryParse(itemNode.getElement('EntryDebit')?.value ?? '0'),
              entryCredit: double.tryParse(itemNode.getElement('EntryCredit')?.value ?? '0'),
              entryNote: itemNode.getElement('EntryNote')?.value,
              entryCurrencyGuid: itemNode.getElement('EntryCurrencyGuid')?.value,
              entryCurrencyVal: double.tryParse(itemNode.getElement('EntryCurrencyVal')?.value ?? '0'),
              entryCostGuid: itemNode.getElement('EntryCostGuid')?.value,
              entryClass: itemNode.getElement('EntryClass')?.value,
              entryNumber: int.tryParse(itemNode.getElement('EntryNumber')?.value ?? '0'),
              entryCustomerGuid: itemNode.getElement('EntryCustomerGuid')?.value,
              entryType: int.tryParse(itemNode.getElement('EntryType')?.value ?? '0'),
            );
          }).toList() ??
          [];

      // إنشاء كائن BondModel
      return BondModel(
        payTypeGuid: node.getElement('PayTypeGuid')?.value,
        payNumber: int.tryParse(node.getElement('PayNumber')?.value ?? '0'),
        payGuid: node.getElement('PayGuid')?.value,
        payBranchGuid: node.getElement('PayBranchGuid')?.value,
        payDate: node.getElement('PayDate')?.value,
        entryPostDate: node.getElement('EntryPostDate')?.value,
        payNote: node.getElement('PayNote')?.value,
        payCurrencyGuid: node.getElement('PayCurrencyGuid')?.value,
        payCurVal: double.tryParse(node.getElement('PayCurVal')?.value ?? '0'),
        payAccountGuid: node.getElement('PayAccountGuid')?.value,
        paySecurity: int.tryParse(node.getElement('PaySecurity')?.value ?? '0'),
        paySkip: int.tryParse(node.getElement('PaySkip')?.value ?? '0'),
        erParentType: int.tryParse(node.getElement('ErParentType')?.value ?? '0'),
        payItems: PayItems(itemList: payItemList),
        e: node.getElement('E')?.value,
      );
    }).toList();
  }
} //
