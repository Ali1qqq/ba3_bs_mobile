import '../../../../core/helper/enums/enums.dart';
import '../../../../core/services/json_file_operations/interfaces/export/json_export_service_base.dart';
import '../../data/models/bill_model.dart';

class BillJsonExport extends JsonExportServiceBase<BillModel> {
  /// Converts the list of `BillModel` to the exportable JSON structure
  @override
  Map<String, dynamic> toExportJson(List<BillModel> itemsModels) {
    return {
      "Bill": itemsModels.map((billModel) {
        return <String, dynamic>{
          "B": {
            "BillTypeGuid": _billTypeGuide(billModel.billTypeModel.billTypeLabel!),
            "BillGuid": billModel.billDetails.billGuid,
            "BillBranch": "",
            "BillPayType": billModel.billDetails.billPayType ?? 0,
            "BillCheckTypeGuid": "",
            "BillNumber": billModel.billDetails.billNumber ?? 0,
            "BillCustPtr": billModel.billDetails.billCustomerId ?? "",
            "BillCustName": billModel.billTypeModel.accounts?[BillAccounts.caches]?.accName,
            // Add the customer name if available
            "BillCurrencyGuid": "884edcde-c172-490d-a2f2-f10a0b90326a",
            "BillCurrencyVal": 1,
            "BillDate": billModel.billDetails.billDate ?? "",
            "BillStoreGuid": billModel.billTypeModel.accounts?[BillAccounts.store]?.id,
            "Note": billModel.billDetails.note ?? "",
            "BillCustAcc": "00000000-0000-0000-0000-000000000000",
            "BillMatAccGuid": "",
            "BillCostGuid": "00000000-0000-0000-0000-000000000000",
            "BillVendorSalesMan": "0,0",
            "BillFirstPay": 0,
            "BillFPayAccGuid": "00000000-0000-0000-0000-000000000000",
            "BillSecurity": 3,
            "BillTransferGuid": "00000000-0000-0000-0000-000000000000",
            "BillFld1": "",
            "BillFld2": "",
            "BillFld3": "",
            "BillFld4": "",
            "ItemsDiscAcc": "",
            "ItemsExtraAccGUID": "",
            "CostAccGUID": "",
            "StockAccGUID": "",
            "BonusAccGUID": "",
            "BonusContraAccGUID": "",
            "VATAccGUID": "",
            "DIscCard": "",
            "BillAddressGUID": "00000000-0000-0000-0000-000000000000"
          },
          "Disc": "", // Discount details if any
          "Items": {
            "I": billModel.items.itemList
                .map((item) => {
                      "MatPtr": item.itemGuid,
                      "QtyBonus": "${item.itemQuantity},0",
                      "Unit": 1, // Customize based on your data
                      "PriceDescExtra": "${item.itemTotalPrice},0,0",
                      "StorePtr": billModel.billTypeModel.accounts?[BillAccounts.store]?.id,
                      "Note": item.itemName,
                      "BonusDisc": 0,
                      "UlQty": "${item.itemQuantity},${item.itemQuantity}",
                      "CostPtr": "",
                      "ClassPtr": "",
                      "ClassPrice": 0,
                      "ExpireProdDate": "1-1-1980,1-1-1980", // Replace with actual expiration dates if available
                      "LengthWidthHeight": "0,0,0,0",
                      "Guid": item.itemGuid,
                      "VatRatio": _calcVatRatio(item.itemVatPrice, item.itemSubTotalPrice),
                      "SoGuid": "",
                      "SoType": 0
                    })
                .toList(),
          }
        };
      }).toList(),
    };
  }

  String _billTypeGuide(String billLabel) => BillType.byLabel(billLabel).typeGuide;

  int _calcVatRatio(double? vat, double? sunTotal) {
    if (vat == null || vat == 0 || sunTotal == null || sunTotal == 0) return 0;
    return ((vat / sunTotal) * 100).round();
  }
}
