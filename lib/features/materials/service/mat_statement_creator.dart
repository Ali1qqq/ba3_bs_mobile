import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_items_extensions.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/mat_statement/mat_statement_model.dart';
import 'package:get/get.dart';

import '../../bill/data/models/bill_items.dart';
import '../../bill/data/models/bill_model.dart';
import '../../bill/services/bill/quantity_strategy.dart';
import '../../bill/services/bill/quantity_strategy_factory.dart';
import 'mat_statement_creator_factory.dart';

abstract class MatStatementCreator<T> {
  List<MatStatementModel> createMatStatement({required T model, List<BillItem> updatedMaterials = const []});
}

class BillMatStatementCreator implements MatStatementCreator<BillModel> {
  @override
  List<MatStatementModel> createMatStatement({required BillModel model, List<BillItem> updatedMaterials = const []}) {
    final QuantityStrategy quantityStrategy = QuantityStrategyFactory.getStrategy(model);

    final mergedItems = model.items.itemList.merge();

    return mergedItems.map(
      (matItem) {
        return MatStatementModel(
            matOrigin: MatStatementCreatorFactory.resolveOriginType(model),
            matId: matItem.itemGuid,
            matName: matItem.itemName,
            originId: model.billId,
            quantity: quantityStrategy.calculateQuantity(matItem.itemQuantity),
            date: model.billDetails.billDate!,
            price: double.parse(matItem.itemTotalPrice) / matItem.itemQuantity,
            note: '${model.billTypeModel.fullName}',
            defQuantity: quantityStrategy.calculateQuantity(updatedMaterials
                    .firstWhereOrNull(
                      (mat) => mat.itemGuid == matItem.itemGuid,
                    )
                    ?.itemQuantity ??
                matItem.itemQuantity));
      },
    ).toList();
  }
}