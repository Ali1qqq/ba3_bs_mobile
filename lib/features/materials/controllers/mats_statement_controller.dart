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
    int counter = 0;
    for (final matStatement in matsStatements) {
      await saveMatStatementModel(matStatementModel: matStatement);
      onProgress?.call((++counter) / matsStatements.length);
      final materialStatementList = await fetchMatStatementById(matStatement.matId!);
      if (materialStatementList != null) {
        if (matStatement.quantity! > 0) {
          await read<MaterialController>().updateMaterialQuantityAndPrice(
              matId: matStatement.matId!,
              quantity: _calculateQuantity(matsStatements),
              quantityInStatement: matStatement.quantity!,
              priceInStatement: matStatement.price!);
        } else {
          await read<MaterialController>().updateMaterialQuantity(matStatement.matId!, matStatement.defQuantity!);
        }
      }
    }
  }

  Future<void> saveMatStatementModel({required MatStatementModel matStatementModel}) async {
    final result = await _matStatementsRepo.save(matStatementModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedStatementModel) => AppUIUtils.onSuccess('تم الحفظ بنجاح'),
    );
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

  Future<void> fetchMatStatements(String name, {required BuildContext context}) async {
    log('name $name');
    final materialByName = _materialsController.getMaterialByName(name);

    log('materialByName ${materialByName?.id}');

    if (!isMatValid(materialByName)) return;

    final result = await _matStatementsRepo.getAll(materialByName!.id!);
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

  int _calculateQuantity(List<MatStatementModel> items) => items.fold(
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
        currentPrice = ((currentPrice * currentQuantity) +
            (matStatementModel.price! * matStatementModel.quantity!)) / (currentQuantity + matStatementModel.quantity!);
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
