import 'dart:developer';

import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/encode_decode_text.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/customer/controllers/customers_controller.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';
import '../../data/models/bill_model.dart';
import '../../use_cases/convert_bills_to_linked_list_use_case.dart';
import '../../use_cases/divide_large_bill_use_case.dart';

class BillImport extends ImportServiceBase<BillModel> with FirestoreSequentialNumbers {
  final DivideLargeBillUseCase _divideLargeBillUseCase = DivideLargeBillUseCase();
  final ConvertBillsToLinkedListUseCase _convertBillsToLinkedListUseCase = ConvertBillsToLinkedListUseCase();

  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<BillModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> billsJson = jsonContent['MainExp']['Export']['Bill'] ?? [];
    bool freeBill = false;
    return billsJson.map((billJson) => BillModel.fromImportedJsonFile(billJson as Map<String, dynamic>, freeBill)).toList();
  }

  late Map<String, int> billsNumbers;

  Future<void> _fetchBillsTypesNumbers() async {
    billsNumbers = {
      for (var billType in BillType.values)
        billType.typeGuide: await getLastNumber(category: ApiConstants.bills, entityType: billType.label)
    };
  }

  List<List<dynamic>> _splitItemsIntoChunks(List items, int maxItemsPerBill) => items.chunkBy((maxItemsPerBill));

  int _getNextBillNumber({required String billTypeGuid, required List<Map<String, dynamic>> items}) {
    if (!billsNumbers.containsKey(billTypeGuid)) {
      throw Exception('Bill type not found');
    }

    final chunks = _splitItemsIntoChunks(items, AppConstants.maxItemsPerBill);

    if (chunks.length > 1) {
      final lastBillNumber = billsNumbers[billTypeGuid];
      billsNumbers[billTypeGuid] = lastBillNumber! + chunks.length;
      return lastBillNumber + 1;
    }

    billsNumbers[billTypeGuid] = billsNumbers[billTypeGuid]! + 1;
    return billsNumbers[billTypeGuid]!;
  }

  _saveBillsTypesNumbers() async {
    billsNumbers.forEach(
      (billTypeGuid, number) async {
        await setLastUsedNumber(ApiConstants.bills, BillType.byTypeGuide(billTypeGuid).label, number);
      },
    );
  }

  /// Extracts order number from "رقم الطلب" or "TABBY-"
  String? _extractOrderNumber(String noteText) {
    // Remove unexpected characters
    noteText = noteText.trim();

    // Match "رقم الطلب" in different formats
    final orderMatch = RegExp(r'رقم\s?الطلب[\s\-=:]*([\d]+)', unicode: true).firstMatch(noteText);
    if (orderMatch != null) {
      // log('Matched Order Number: ${orderMatch.group(1)}', name: 'Regex');
      return orderMatch.group(1);
    }

    // Match "TABBY-" or "tabby-" followed by numbers (case-insensitive)
    final tabbyMatch = RegExp(r'tabby-(\d+)', caseSensitive: false).firstMatch(noteText);
    if (tabbyMatch != null) {
      // log('Matched Tabby Order Number: ${tabbyMatch.group(1)}', name: 'Regex');
      return tabbyMatch.group(1);
    }

    return null;
  }

  @override
  Future<List<BillModel>> fromImportXml(XmlDocument document) async {
    await _fetchBillsTypesNumbers();

    final billsXml = document.findAllElements('Bill');
    final materialXml = document.findAllElements('M');
    final sellersXml = document.findAllElements('Q');
    final accountXml = document.findAllElements('A');
    final customerXml = document.findAllElements('Cu');

    Map<String, String> matNameWithId = {};
    Map<String, String> accountWithId = {};
    Map<String, String> customerWithId = {};

    for (var mat in materialXml) {
      String matGuid = mat.findElements('mptr').first.value!;
      String matName = mat.findElements('MatName').first.value!;
      matNameWithId[matGuid] = matName.encodeProblematic();
    }
    for (var acc in accountXml) {
      String accId = acc.findElements('AccPtr').first.value!;
      String accName = acc.findElements('AccName').first.value!;
      accountWithId[accId] = accName;
    }
    // accountWithId['00000000-0000-0000-0000-000000000000']='';
    for (var cu in customerXml) {
      String cuGuid = cu.findElements('cptr').first.value!;
      String cuName = cu.findElements('CustName').first.value!;
      customerWithId[cuGuid] = cuName;
    }

    Map<String, String> sellerNameID = {};

    for (var sel in sellersXml) {
      String selGuid = sel.findElements('CostGuid').first.value!;
      String selName = sel.findElements('CostName').first.value!;
      sellerNameID[selGuid] = selName;
    }

    List<BillModel> bills = [];

    log(billsXml.length.toString(), name: 'billsXml');

    for (var billElement in billsXml) {
      String? customerPhone;
      String? orderNumber;

      final noteText = billElement.findElements('B').single.findElements('Note').single.value!.trim();

      // log('Processing Note: $noteText', name: 'XML Processing');

      // Phone number detection
      if (RegExp(r'^05\d{8}$').hasMatch(noteText)) {
        // log('Detected Phone Number: $noteText', name: 'Phone');
        customerPhone = noteText;
      }

      // Extract order number
      String? extractedOrderNumber = _extractOrderNumber(noteText);
      if (extractedOrderNumber != null) {
        // log('Extracted Order Number: $extractedOrderNumber', name: 'Order Number');
        orderNumber = extractedOrderNumber;
      }

      final itemsElement = billElement.findElements('Items').single;
      final List<Map<String, dynamic>> itemsJson = itemsElement.findElements('I').map((iElement) {
        if (read<MaterialController>().getMaterialByName(matNameWithId[iElement.findElements('MatPtr').single.value]) == null) {
          log('name ${matNameWithId[iElement.findElements('MatPtr').single.value]}', name: 'XML Processing name');
        }
        return {
          'MatPtr': read<MaterialController>().getMaterialByName(matNameWithId[iElement.findElements('MatPtr').single.value])!.id,
          // 'MatPtr': iElement.findElements('MatPtr').single.value,

          /// to get the same material name in our database
          'MatName': read<MaterialController>().getMaterialByName(matNameWithId[iElement.findElements('MatPtr').single.value])!.matName,
          // 'MatName': matNameWithId[iElement.findElements('MatPtr').single.value],
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

      Map<String, dynamic> billJson = {
        'B': {
          'BillTypeGuid': billElement.findElements('B').single.findElements('BillTypeGuid').single.value,
          'BillGuid': billElement.findElements('B').single.findElements('BillGuid').single.value,
          'BillBranch': billElement.findElements('B').single.findElements('BillBranch').single.value,
          'BillPayType': billElement.findElements('B').single.findElements('BillPayType').single.value,
          'BillCheckTypeGuid': billElement.findElements('B').single.findElements('BillCheckTypeGuid').single.value,
          'BillNumber': _getNextBillNumber(
            billTypeGuid: billElement.findElements('B').single.findElements('BillTypeGuid').single.value!,
            items: itemsJson,
          ),
          'BillMatAccGuid': billElement.findElements('B').single.findElements('BillMatAccGuid').single.value,
          'BillCustPtr': read<CustomersController>()
                  .getCustomerById(customerWithId[billElement.findElements('B').single.findElements('BillCustAcc').single.value])
                  ?.id ??
              '',
          'BillCustAccId': read<AccountsController>()
              .getAccountIdByName(accountWithId[billElement.findElements('B').single.findElements('BillCustAcc').single.value]),
          // 'BillCustAccId': billElement.findElements('B').single.findElements('BillCustAcc').single.value,
          'BillCustAccName': accountWithId[billElement.findElements('B').single.findElements('BillCustAcc').single.value],
          'BillCurrencyGuid': billElement.findElements('B').single.findElements('BillCurrencyGuid').single.value,
          'BillCurrencyVal': billElement.findElements('B').single.findElements('BillCurrencyVal').single.value,
          'BillDate': billElement.findElements('B').single.findElements('BillDate').single.value,
          'BillStoreGuid': billElement.findElements('B').single.findElements('BillStoreGuid').single.value,
          'Note': billElement.findElements('B').single.findElements('Note').single.value,
          'CustomerPhone': customerPhone,
          'OrderNumber': orderNumber,
          'BillCostGuid': read<SellersController>()
              .getSellerIdByName(sellerNameID[billElement.findElements('B').single.findElements('BillCostGuid').single.value]),
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

      billJson['Items'] = {"I": itemsJson};
      bool freeBill = false;

      final BillModel bill = BillModel.fromImportedJsonFile(billJson, freeBill);

      final List<BillModel> splitBills = _divideLargeBillUseCase.execute(bill);
      bills.addAll(splitBills);
    }
    log(bills.length.toString(), name: 'bills');
    // 🔹 Use the Use Case for linking bills
    final linkedBills = _convertBillsToLinkedListUseCase.execute(bills);

    // return [];
    await _saveBillsTypesNumbers();

    return linkedBills;
  }
}