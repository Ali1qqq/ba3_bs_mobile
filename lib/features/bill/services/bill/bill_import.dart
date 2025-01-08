import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';
import '../../data/models/bill_model.dart';

class BillImport extends ImportServiceBase<BillModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<BillModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> billsJson = jsonContent['MainExp']['Export']['Bill'] ?? [];

    return billsJson.map((billJson) => BillModel.fromImportedJsonFile(billJson as Map<String, dynamic>)).toList();
  }

  @override
  List<BillModel> fromImportXml(XmlDocument document) {
    final billsXml = document.findAllElements('Bill');

    List<BillModel> bills = billsXml.map((billElement) {
      Map<String, dynamic> billJson = {
        'B': {
          'BillTypeGuid': billElement.findElements('B').single.findElements('BillTypeGuid').single.value,
          'BillGuid': billElement.findElements('B').single.findElements('BillGuid').single.value,
          'BillBranch': billElement.findElements('B').single.findElements('BillBranch').single.value,
          'BillPayType': billElement.findElements('B').single.findElements('BillPayType').single.value,
          'BillCheckTypeGuid': billElement.findElements('B').single.findElements('BillCheckTypeGuid').single.value,
          'BillNumber': billElement.findElements('B').single.findElements('BillNumber').single.value,
          'BillCustPtr': billElement.findElements('B').single.findElements('BillCustPtr').single.value,
          'BillCustName': billElement.findElements('B').single.findElements('BillCustName').single.value,
          'BillCurrencyGuid': billElement.findElements('B').single.findElements('BillCurrencyGuid').single.value,
          'BillCurrencyVal': billElement.findElements('B').single.findElements('BillCurrencyVal').single.value,
          'BillDate': billElement.findElements('B').single.findElements('BillDate').single.value,
          'BillStoreGuid': billElement.findElements('B').single.findElements('BillStoreGuid').single.value,
          'Note': billElement.findElements('B').single.findElements('Note').single.value,
          'BillCustAcc': billElement.findElements('B').single.findElements('BillCustAcc').single.value,
          'BillMatAccGuid': billElement.findElements('B').single.findElements('BillMatAccGuid').single.value,
          'BillCostGuid': billElement.findElements('B').single.findElements('BillCostGuid').single.value,
          'BillVendorSalesMan': billElement.findElements('B').single.findElements('BillVendorSalesMan').single.value,
          'BillFirstPay': billElement.findElements('B').single.findElements('BillFirstPay').single.value,
          'BillFPayAccGuid': billElement.findElements('B').single.findElements('BillFPayAccGuid').single.value,
          'BillSecurity': billElement.findElements('B').single.findElements('BillSecurity').single.value,
          'BillTransferGuid': billElement.findElements('B').single.findElements('BillTransferGuid').single.value,
          'BillFld1': billElement.findElements('B').single.findElements('BillFld1').single.value,
          'BillFld2': billElement.findElements('B').single.findElements('BillFld2').single.value,
          'BillFld3': billElement.findElements('B').single.findElements('BillFld3').single.value,
          'BillFld4': billElement.findElements('B').single.findElements('BillFld4').single.value,
          'ItemsDiscAcc': billElement.findElements('B').single.findElements('ItemsDiscAcc').single.value,
          'ItemsExtraAccGUID': billElement.findElements('B').single.findElements('ItemsExtraAccGUID').single.value,
          'CostAccGUID': billElement.findElements('B').single.findElements('CostAccGUID').single.value,
          'StockAccGUID': billElement.findElements('B').single.findElements('StockAccGUID').single.value,
          'BonusAccGUID': billElement.findElements('B').single.findElements('BonusAccGUID').single.value,
          'BonusContraAccGUID': billElement.findElements('B').single.findElements('BonusContraAccGUID').single.value,
          'VATAccGUID': billElement.findElements('B').single.findElements('VATAccGUID').single.value,
          'DIscCard': billElement.findElements('B').single.findElements('DIscCard').single.value,
          'BillAddressGUID': billElement.findElements('B').single.findElements('BillAddressGUID').single.value,
        }
      };

      final itemsElement = billElement.findElements('Items').single;
      final itemsJson = itemsElement.findElements('I').map((iElement) {
        return {
          'MatPtr': iElement.findElements('MatPtr').single.value,
          'QtyBonus': iElement.findElements('QtyBonus').single.value,
          'Unit': iElement.findElements('Unit').single.value,
          'PriceDescExtra': iElement.findElements('PriceDescExtra').single.value,
          'StorePtr': iElement.findElements('StorePtr').single.value,
          'Note': iElement.findElements('Note').single.value,
          'BonusDisc': iElement.findElements('BonusDisc').single.value,
          'UlQty': iElement.findElements('UlQty').single.value,
          'CostPtr': iElement.findElements('CostPtr').single.value,
          'ClassPtr': iElement.findElements('ClassPtr').single.value,
          'ClassPrice': iElement.findElements('ClassPrice').single.value,
          'ExpireProdDate': iElement.findElements('ExpireProdDate').single.value,
          'LengthWidthHeight': iElement.findElements('LengthWidthHeight').single.value,
          'Guid': iElement.findElements('Guid').single.value,
          'VatRatio': iElement.findElements('VatRatio').single.value,
          'SoGuid': iElement.findElements('SoGuid').single.value,
          'SoType': iElement.findElements('SoType').single.value,
        };
      }).toList();

      billJson['Items'] = {"I": itemsJson};

      return BillModel.fromImportedJsonFile(billJson);
    }).toList();

    return bills;
  }
}
