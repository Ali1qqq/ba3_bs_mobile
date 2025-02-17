import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/materials/material_model.dart';
import 'package:ba3_bs_mobile/features/materials/ui/screens/material_statement_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../data/models/mat_statement/mat_statement_model.dart';
import 'material_controller.dart';

class MaterialsStatementController extends GetxController with FloatingLauncher, AppNavigator {
  // Dependencies
  final CompoundDatasourceRepository<MatStatementModel, String> _matStatementsRepo;
  final MaterialController _materialsController = read<MaterialController>();

  MaterialsStatementController(this._matStatementsRepo);

  Future<void> saveAllMatsStatementsModels({
    required List<MatStatementModel> matsStatements,
    void Function(double progress)? onProgress,
  }) async {
    // 1. We call `saveAllNested`, which returns a Map<String, List<MatStatementModel>>
    final result = await _matStatementsRepo.saveAllNested(
        items: matsStatements, itemIdentifiers: matsStatements.select((matsStatements) => matsStatements.matId), onProgress: onProgress);

    // 2. Flatten the map into a single list of MatStatementModel
    //    mapOfStatements.values is an Iterable<List<MatStatementModel>>
    //    We expand those lists, then .toList() the result
    result.fold(
          (failure) => AppUIUtils.onFailure(failure.message),
          (savedStatements) =>
      (), /*onSaveAllMatsStatementsModelsSuccess(
        mapOfStatements: matsStatements.groupBy((matsStatements) => matsStatements.matId!),
        onProgress: onProgress,
      ),*/
    );
  }

  Future<void> onSaveAllMatsStatementsModelsSuccess({
    required Map<String, List<MatStatementModel>> mapOfStatements,
    void Function(double progress)? onProgress,
  }) async {
    final allSavedStatements = mapOfStatements.values.expand((list) => list).toList(); // List<MatStatementModel>

    // If we have none, exit early
    if (allSavedStatements.isEmpty) {
      AppUIUtils.onSuccess('تم الحفظ بنجاح (لا توجد عناصر للحفظ)');
      return;
    }

    int completed = 0;
    final total = allSavedStatements.length;
    AppUIUtils.onSuccess('تم الحفظ بنجاح'); // from the nested save

    // 3. Update each material's quantity in parallel

    await Future.wait(
      allSavedStatements.map(
            (statement) async {
          if (statement.defQuantity != null && statement.defQuantity! > 0) {
            await read<MaterialController>().updateMaterialQuantityAndPrice(
              matId: statement.matId!,
              quantity: statement.defQuantity!,
              quantityInStatement: statement.quantity!,
              priceInStatement: statement.price!,
            );
          } else {
            await read<MaterialController>().updateMaterialQuantity(
              statement.matId!,
              statement.defQuantity!,
            );
          }

          // Update progress after each statement finishes
          onProgress?.call(++completed / total);
        },
      ),
    );
  }

  setupAllMaterials() async {
    int i = 0;
    for (final material in read<MaterialController>().materials) {
      i++;

      final materialStatementList = await fetchMatStatementById(material.id!);
      if (materialStatementList != null) {
        log(i.toString());
        await read<MaterialController>().updateMaterialQuantityAndPriceWhenDeleteBill(
            matId: material.id!,
            quantity: _calculateQuantity(materialStatementList),
            currentMinPrice: _calculateMinPrice(materialStatementList));
      }
    }
  }

  Future<void> deleteMatStatementModel(MatStatementModel matStatementModel) async {
    final result = await _matStatementsRepo.delete(matStatementModel);

    result.fold(
          (failure) => AppUIUtils.onFailure(failure.message),
          (_) => AppUIUtils.onSuccess('تم الحذف بنجاح'),
    );

    final materialStatementList = await fetchMatStatementById(matStatementModel.matId!);
    if (materialStatementList != null) {
      if (matStatementModel.quantity! < 0) {
        await read<MaterialController>().updateMaterialQuantityAndPriceWhenDeleteBill(
            matId: matStatementModel.matId!,
            quantity: _calculateQuantity(materialStatementList),
            currentMinPrice: _calculateMinPrice(materialStatementList));
      } else {
        await read<MaterialController>().setMaterialQuantity(
          matStatementModel.matId!,
          _calculateQuantity(materialStatementList),
        );
      }
    }
  }

  Future<void> deleteAllMatStatementModel(List<MatStatementModel> matStatementsModels) async {
    final List<Future<void>> deletedTasks = [];
    final errors = <String>[];

    for (final matStatementModel in matStatementsModels) {
      deletedTasks.add(
        deleteMatStatementModel(matStatementModel),
      );
    }

    await Future.wait(deletedTasks);

    if (errors.isNotEmpty) {
      AppUIUtils.onFailure('Some deletions failed: ${errors.join(', ')}');
    }
  }

  final List<MatStatementModel> matStatements = [];
  MaterialModel? selectedMat;

  bool isLoadingPlutoGrid = false;

  int totalQuantity = 0;

  bool isMatValid(MaterialModel? materialByName) {
    if (materialByName == null || materialByName.id == null) {
      AppUIUtils.onFailure('فشل في ايجاد الماده!');
      selectedMat = null;
      return false;
    }

    selectedMat = materialByName;
    return true;
  }

  Future<void> fetchMatStatements(MaterialModel materialModel, {required BuildContext context}) async {
    log('name ${materialModel.matName}');
    // final materialByName = _materialsController.getMaterialByName(name);

    log('materialByName ${materialModel.id}');

    if (!isMatValid(materialModel)) return;

    final result = await _matStatementsRepo.getAll(materialModel.id!);
    result.fold(
          (failure) => AppUIUtils.onFailure(failure.message),
          (fetchedItems) {
        matStatements.assignAll(fetchedItems.map((item) => item).toList());

        launchFloatingWindow(
          context: context,
          floatingScreen: MaterialStatementScreen(),
          minimizedTitle: screenTitle,
        );

        // filterByDate();
        _calculateValues(fetchedItems);
      },
    );
  }

  Future<List<MatStatementModel>?> fetchMatStatementById(String matId) async {
    final result = await _matStatementsRepo.getAll(matId);
    return result.fold(
          (failure) => AppUIUtils.onFailure(failure.message),
          (fetchedItems) => fetchedItems,
    );
  }

  /// Calculates debit, credit, and total values
  void _calculateValues(List<MatStatementModel> items) {
    if (items.isEmpty) {
      _resetValues();
    } else {
      _updateValues(items);
    }
  }

  _resetValues() {
    totalQuantity = 0;
  }

  _updateValues(List<MatStatementModel> items) {
    totalQuantity = _calculateQuantity(items);
  }

  int _calculateQuantity(List<MatStatementModel> items) =>
      items.fold(
        0,
            (sum, item) => sum + (item.quantity ?? 0),
      );

  double _calculateMinPrice(List<MatStatementModel> items) {
    if (items.isEmpty) return 0.0;
    items.sortBy((item) => item.date!);
    double currentPrice = 0.0;
    int currentQuantity = 0;
    for (final matStatementModel in items) {
      if (matStatementModel.quantity! > 0) {
        currentPrice = ((currentPrice * currentQuantity) + (matStatementModel.price! * matStatementModel.quantity!)) /
            (currentQuantity + matStatementModel.quantity!);
        currentQuantity += matStatementModel.quantity!;
      } else {
        currentQuantity += matStatementModel.quantity!;
      }
    }
    log('final price is $currentPrice');
    return currentPrice;
  }

  String get screenTitle => 'حركات ${selectedMat?.matName}';
}