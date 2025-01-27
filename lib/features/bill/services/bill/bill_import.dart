import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';
import '../../data/models/bill_model.dart';

class BillImport extends ImportServiceBase<BillModel> with FirestoreSequentialNumbers {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<BillModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> billsJson = jsonContent['MainExp']['Export']['Bill'] ?? [];

    return billsJson.map((billJson) => BillModel.fromImportedJsonFile(billJson as Map<String, dynamic>)).toList();
  }

  late Map<String, int> billsNumbers;

  Future<void> initializeNumbers() async {
    billsNumbers = {
      for (var billType in BillType.values)
        billType.typeGuide: await getLastNumber(
          category: ApiConstants.bills,
          entityType: billType.label,
          // number: 0,
        )
    };
  }

  int getLastBillNumber(String billTypeGuid) {
    if (!billsNumbers.containsKey(billTypeGuid)) {
      throw Exception('Bill type not found');
    }
    billsNumbers[billTypeGuid] = billsNumbers[billTypeGuid]! + 1;
    return billsNumbers[billTypeGuid]!;
  }

  setLastNumber() async {
    billsNumbers.forEach(
      (billTypeGuid, number) async {
        await satNumber(ApiConstants.bills, BillType.byTypeGuide(billTypeGuid).label, number);
      },
    );
  }

  @override
  Future<List<BillModel>> fromImportXml(XmlDocument document) async {
    await initializeNumbers();
    final billsXml = document.findAllElements('Bill');
    final materialXml = document.findAllElements('M');
    final sellersXml = document.findAllElements('Q');

    Map<String, String> matNameWithId = {};

    for (var mat in materialXml) {
      String matGuid = mat.findElements('mptr').first.value ?? '';
      String amtName = mat.findElements('MatName').first.value ?? '';
      matNameWithId[matGuid] = amtName;
    }

    Map<String, String> sellerNameID = {};

    for (var sel in sellersXml) {
      String selGuid = sel.findElements('CostGuid').first.value ?? '';
      String selName = sel.findElements('CostName').first.value ?? '';
      sellerNameID[selGuid] = selName;
    }
    await Future.delayed(Durations.long4);
    // matNameWithId.forEach((key, value ??'') => log('$value ??''   $key'),);
    List<BillModel> bills = billsXml.map((billElement) {
      // String customerId =
      //     read<AccountsController>().getAccountIdByName(billElement.findElements('B').single.findElements('BillCustName').single.value ??'');
      Map<String, dynamic> billJson = {
        'B': {
          'BillTypeGuid': billElement.findElements('B').single.findElements('BillTypeGuid').single.value ?? '',
          'BillGuid': billElement.findElements('B').single.findElements('BillGuid').single.value ?? '',
          'BillBranch': billElement.findElements('B').single.findElements('BillBranch').single.value ?? '',
          'BillPayType': billElement.findElements('B').single.findElements('BillPayType').single.value ?? '',
          'BillCheckTypeGuid': billElement.findElements('B').single.findElements('BillCheckTypeGuid').single.value ?? '',
          'BillNumber': getLastBillNumber(billElement.findElements('B').single.findElements('BillTypeGuid').single.value ??
              '') /*billElement.findElements('B').single.findElements('BillNumber').single.value ??''*/,
          'BillCustPtr': billElement.findElements('B').single.findElements('BillCustAcc').single.value ?? '',
          // 'BillCustPtr': customerId,
          'BillCustName': read<AccountsController>()
              .getAccountNameById(billElement.findElements('B').single.findElements('BillCustAcc').single.value ?? ''),
          'BillCurrencyGuid': billElement.findElements('B').single.findElements('BillCurrencyGuid').single.value ?? '',
          'BillCurrencyVal': billElement.findElements('B').single.findElements('BillCurrencyVal').single.value ?? '',
          'BillDate': billElement.findElements('B').single.findElements('BillDate').single.value ?? '',
          'BillStoreGuid': billElement.findElements('B').single.findElements('BillStoreGuid').single.value ?? '',
          'Note': billElement.findElements('B').single.findElements('Note').single.value ?? '',
          'BillCustAcc': billElement.findElements('B').single.findElements('BillCustAcc').single.value ?? '',
          'BillMatAccGuid': billElement.findElements('B').single.findElements('BillMatAccGuid').single.value ?? '',
          'BillCostGuid': read<SellersController>()
              .getSellerIdByName(sellerNameID[billElement.findElements('B').single.findElements('BillCostGuid').single.value ?? '']),
          // 'BillCostGuid': billElement.findElements('B').single.findElements('BillCostGuid').single.value ??'',
          'BillVendorSalesMan': billElement.findElements('B').single.findElements('BillVendorSalesMan').single.value ?? '',
          'BillFirstPay': billElement.findElements('B').single.findElements('BillFirstPay').single.value ?? '',
          'BillFPayAccGuid': billElement.findElements('B').single.findElements('BillFPayAccGuid').single.value ?? '',
          'BillSecurity': billElement.findElements('B').single.findElements('BillSecurity').single.value ?? '',
          'BillTransferGuid': billElement.findElements('B').single.findElements('BillTransferGuid').single.value ?? '',
          'BillFld1': billElement.findElements('B').single.findElements('BillFld1').single.value ?? '',
          'BillFld2': billElement.findElements('B').single.findElements('BillFld2').single.value ?? '',
          'BillFld3': billElement.findElements('B').single.findElements('BillFld3').single.value ?? '',
          'BillFld4': billElement.findElements('B').single.findElements('BillFld4').single.value ?? '',
          'ItemsDiscAcc': billElement.findElements('B').single.findElements('ItemsDiscAcc').single.value ?? '',
          'ItemsExtraAccGUID': billElement.findElements('B').single.findElements('ItemsExtraAccGUID').single.value ?? '',
          'CostAccGUID': billElement.findElements('B').single.findElements('CostAccGUID').single.value ?? '',
          'StockAccGUID': billElement.findElements('B').single.findElements('StockAccGUID').single.value ?? '',
          'BonusAccGUID': billElement.findElements('B').single.findElements('BonusAccGUID').single.value ?? '',
          'BonusContraAccGUID': billElement.findElements('B').single.findElements('BonusContraAccGUID').single.value ?? '',
          'VATAccGUID': billElement.findElements('B').single.findElements('VATAccGUID').single.value ?? '',
          'DIscCard': billElement.findElements('B').single.findElements('DIscCard').single.value ?? '',
          'BillAddressGUID': billElement.findElements('B').single.findElements('BillAddressGUID').single.value ?? '',
        }
      };

      final itemsElement = billElement.findElements('Items').single;
      final itemsJson = itemsElement.findElements('I').map((iElement) {
        return {
          'MatPtr': read<MaterialController>().getMaterialByName(matNameWithId[iElement.findElements('MatPtr').single.value ?? ''])!.id,
          'MatName': matNameWithId[iElement.findElements('MatPtr').single.value ?? ''],
          'QtyBonus': iElement.findElements('QtyBonus').single.value ?? '',
          'Unit': iElement.findElements('Unit').single.value ?? '',
          'PriceDescExtra': iElement.findElements('PriceDescExtra').single.value ?? '',
          'StorePtr': iElement.findElements('StorePtr').single.value ?? '',
          'Note': iElement.findElements('Note').single.value ?? '',
          'BonusDisc': iElement.findElements('BonusDisc').single.value ?? '',
          'UlQty': iElement.findElements('UlQty').single.value ?? '',
          'CostPtr': iElement.findElements('CostPtr').single.value ?? '',
          'ClassPtr': iElement.findElements('ClassPtr').single.value ?? '',
          'ClassPrice': iElement.findElements('ClassPrice').single.value ?? '',
          'ExpireProdDate': iElement.findElements('ExpireProdDate').single.value ?? '',
          'LengthWidthHeight': iElement.findElements('LengthWidthHeight').single.value ?? '',
          'Guid': iElement.findElements('Guid').single.value ?? '',
          'VatRatio': iElement.findElements('VatRatio').single.value ?? '',
          'SoGuid': iElement.findElements('SoGuid').single.value ?? '',
          'SoType': iElement.findElements('SoType').single.value ?? '',
        };
      }).toList();

      billJson['Items'] = {"I": itemsJson};

      return BillModel.fromImportedJsonFile(billJson);
    }).toList();
    await setLastNumber();
    return bills;
  }
}
