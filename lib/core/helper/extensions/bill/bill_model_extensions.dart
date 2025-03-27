import '../../../../features/bill/data/models/bill_model.dart';
import '../../../../features/patterns/data/models/bill_type_model.dart';
import '../../enums/enums.dart';

extension BillModelExtensions on BillModel {
  /// Retrieves the BillType from the BillModel.
  BillType get billType => BillType.byLabel(billTypeModel.billTypeLabel!);

  /// Checks if the BillType is related to a **purchase transaction**.
  bool get isPurchaseRelated {
    return {
      BillType.purchase,
      BillType.salesReturn,
      BillType.adjustmentEntry,
      BillType.firstPeriodInventory,
      BillType.transferIn,
    }.contains(billType);
  }

  /// Checks if the BillType is related to a **sales transaction**.
  bool get isSellRelated {
    return {
      BillType.sales,
      BillType.purchaseReturn,
      BillType.outputAdjustment,
      BillType.transferOut,
    }.contains(billType);
  }
}

extension BillTypeModelExtensions on BillTypeModel {
  /// Retrieves the BillType from the BillModel.
  BillType get billType => BillType.byLabel(billTypeLabel!);

  /// Checks if the BillType is related to a **purchase transaction**.
  bool get isPurchaseRelated {
    return {
      BillType.purchase,
      BillType.salesReturn,
      BillType.adjustmentEntry,
      BillType.firstPeriodInventory,
      BillType.transferIn,
    }.contains(billType);
  }

  /// Checks if the BillType is related to a **sales transaction**.
  bool get isSellRelated {
    return {
      BillType.sales,
      BillType.purchaseReturn,
      BillType.outputAdjustment,
      BillType.transferOut,
    }.contains(billType);
  }
}
