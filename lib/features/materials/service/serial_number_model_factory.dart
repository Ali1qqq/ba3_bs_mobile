import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_model_extensions.dart';

import '../../bill/data/models/bill_model.dart';
import '../data/models/materials/material_model.dart';

class SerialNumberModelFactory {
  static SerialNumberModel getModel(String serialText, {required BillModel billModel, required MaterialModel material}) {
    return SerialNumberModel(
      serialNumber: serialText,
      matId: material.id,
      matName: material.matName,
      transactions: [
        _createTransaction(serialText, billModel),
      ],
    );
  }

  /// Creates a SerialTransactionModel based on whether it's a purchase or a sale.
  static SerialTransactionModel _createTransaction(String serialText, BillModel billModel) {
    bool isPurchase = billModel.isPurchaseRelated;

    return SerialTransactionModel(
      buyBillId: isPurchase ? billModel.billId : null,
      buyBillNumber: isPurchase ? billModel.billDetails.billNumber : null,
      buyBillTypeId: isPurchase ? billModel.billTypeModel.billTypeId : null,
      sellBillId: !isPurchase ? billModel.billId : null,
      sellBillNumber: !isPurchase ? billModel.billDetails.billNumber : null,
      sellBillTypeId: !isPurchase ? billModel.billTypeModel.billTypeId : null,
      entryDate: billModel.billDetails.billDate,
      sold: !isPurchase,
      // If it's a sale, sold = true; otherwise, false.
      transactionOrigin: SerialTransactionOrigin(
        serialNumber: serialText,
        matId: billModel.billTypeModel.billTypeId, // Assuming billTypeId is linked to material
        matName: billModel.billTypeModel.billTypeLabel,
      ),
    );
  }
}