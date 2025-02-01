import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs_mobile/features/bill/services/bill/quantity_strategy.dart';

import '../../../../core/helper/enums/enums.dart';

class QuantityStrategyFactory {
  static QuantityStrategy getStrategy(BillModel billModel) {
    final BillType billType = BillType.byLabel(billModel.billTypeModel.billTypeLabel!);

    switch (billType) {
      case BillType.purchase:
      case BillType.salesReturn:
      case BillType.adjustmentEntry:
      case BillType.firstPeriodInventory:
      case BillType.transferIn:
        return AddQuantityStrategy();

      case BillType.sales:
      case BillType.purchaseReturn:
      case BillType.outputAdjustment:
      case BillType.transferOut:
        return SubtractQuantityStrategy();
    }
  }
}
