import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_items_extensions.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/mats_statement_controller.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/mat_statement/mat_statement_model.dart';
import 'package:ba3_bs_mobile/features/materials/service/mat_statement_creator_factory.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../bill/data/models/bill_items.dart';
import '../../bill/services/bill/quantity_strategy.dart';
import '../../bill/services/bill/quantity_strategy_factory.dart';
import 'mat_statement_creator.dart';

mixin MatsStatementsGenerator {
  final MaterialsStatementController _materialsStatementController = read<MaterialsStatementController>();
  int j = 0;

  Future<void> createAndStoreMatsStatements({
    required List sourceModels,
    void Function(double progress)? onProgress,
  }) async {
    final matsStatementsModels = _generateMatsStatementsModels(sourceModels);
    await _materialsStatementController.saveAllMatsStatementsModels(matsStatements: matsStatementsModels, onProgress: onProgress);
    log("j is  ${j++}");
  }

  List<MatStatementModel> _generateMatsStatementsModels(List sourceModels) {
    return sourceModels.expand<MatStatementModel>(
      (model) {
        final MatStatementCreator creator = MatStatementCreatorFactory.resolveMatStatementCreator(model);
        return creator.createMatStatement(model: model);
      },
    ).toList();
  }

  Future<void> createAndStoreMatStatement<T>({
    required T model,
    List<BillItem> deletedMaterials = const [],
    List<BillItem> updatedMaterials = const [],
  }) async {
    final MatStatementCreator creator = MatStatementCreatorFactory.resolveMatStatementCreator(model);
    final matsStatementsModels = creator.createMatStatement(model: model, updatedMaterials: updatedMaterials);

    await _materialsStatementController.saveAllMatsStatementsModels(matsStatements: matsStatementsModels);

    if (deletedMaterials.isNotEmpty) {
      final originId = matsStatementsModels.first.originId;

      final matStatementsToDelete = deletedMaterials.map(
        (material) {
          final matId = material.itemGuid;

          return MatStatementModel(
            matId: matId,
            originId: originId,
          );
        },
      ).toList();

      await _materialsStatementController.deleteAllMatStatementModel(matStatementsToDelete);
    }
  }

  Future<void> deleteMatsStatementsModels(BillModel billModel) async {
    final String originId = billModel.billId!;
    final QuantityStrategy quantityStrategy = QuantityStrategyFactory.getStrategy(billModel);

    final mergedBillItems = billModel.items.itemList.merge();

    final matStatementsModels = mergedBillItems
        .map(
          (item) => MatStatementModel(
            matId: item.itemGuid,
            originId: originId,
            quantity: -quantityStrategy.calculateQuantity(item.itemQuantity),
          ),
        )
        .toList();

    await _materialsStatementController.deleteAllMatStatementModel(matStatementsModels);
  }
}