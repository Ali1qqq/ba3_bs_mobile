import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../data/models/mat_statement/mat_statement_model.dart';
import '../data/models/material_model.dart';
import '../ui/screens/material_statement_screen.dart';
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
  }

  Future<void> deleteAllMatStatementModel(List<MatStatementModel> matStatementsModels) async {
    final List<Future<void>> deletedTasks = [];
    final errors = <String>[];

    for (final matStatementModel in matStatementsModels) {
      deletedTasks.add(
        _matStatementsRepo.delete(matStatementModel).then(
          (deleteResult) {
            deleteResult.fold(
              (failure) => errors.add(failure.message), // Collect errors.
              (_) {},
            );
          },
        ),
      );
    }

    await Future.wait(deletedTasks);

    if (errors.isNotEmpty) {
      AppUIUtils.onFailure('Some deletions failed: ${errors.join(', ')}');
    }
  }

// // Text Controllers
// final productForSearchController = TextEditingController();
// final groupForSearchController = TextEditingController();
// final accountNameController = TextEditingController();
// final storeForSearchController = TextEditingController();
// final startDateController = TextEditingController()..text = _formattedToday;
// final endDateController = TextEditingController()..text = _formattedToday;
//
  // Data
  final List<MatStatementModel> matStatements = [];
  MaterialModel? selectedMat;

// List<EntryBondItemModel> filteredEntryBondItems = [];
//

  // State variables
  bool isLoadingPlutoGrid = false;

  int totalQuantity = 0;

// double debitValue = 0.0;
// double creditValue = 0.0;

// @override
// void onInit() {
//   super.onInit();
//   resetFields();
// }
//
// /// Clears fields and resets state
// void resetFields({String? initialAccount}) {
//   productForSearchController.clear();
//   groupForSearchController.clear();
//   storeForSearchController.clear();
//   startDateController.text = _formattedToday;
//   endDateController.text = _formattedToday;
//
//   if (initialAccount != null) {
//     accountNameController.text = initialAccount;
//   } else {
//     accountNameController.clear();
//   }
// }
//
// // Event Handlers
// void onAccountNameSubmitted(String text, BuildContext context) async {
//   final convertArabicNumbers = AppUIUtils.convertArabicNumbers(text);
//
//   AccountModel? accountModel = await _materialsController.openAccountSelectionDialog(
//     query: convertArabicNumbers,
//     context: context,
//   );
//   if (accountModel != null) {
//     accountNameController.text = accountModel.accName!;
//   }
// }
//
// void onStartDateSubmitted(String text) {
//   startDateController.text = AppUIUtils.getDateFromString(text);
// }
//
// void onEndDateSubmitted(String text) {
//   endDateController.text = AppUIUtils.getDateFromString(text);
// }
//

  bool isMatValid(MaterialModel? materialByName) {
    if (materialByName == null || materialByName.id == null) {
      AppUIUtils.onFailure('فشل في ايجاد الماده!');
      selectedMat = null;
      return false;
    }

    selectedMat = materialByName;
    return true;
  }

// Fetch bond items for the selected account
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

// void filterByDate() {
//   final DateFormat dateFormat = DateFormat('yyyy-MM-dd'); // Format for start and end dates
//
//   final DateTime startDate = dateFormat.parse(startDateController.text);
//   final DateTime endDate = dateFormat.parse(endDateController.text);
//
//   filteredEntryBondItems = entryBondItems.where((item) {
//     final String? entryBondItemDateStr = item.date; // Ensure `date` is the correct field
//     if (entryBondItemDateStr == null) return false;
//
//     DateTime? entryBondItemDate;
//     try {
//       entryBondItemDate = dateFormat.parse(entryBondItemDateStr);
//     } catch (e) {
//       log('Error parsing item.date: $entryBondItemDateStr. Error: $e');
//       return false; // Skip invalid date formats
//     }
//
//     return entryBondItemDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
//         entryBondItemDate.isBefore(endDate.add(const Duration(days: 1)));
//   }).toList();
// }
//
// /// Navigation handler
// void navigateToAccountStatementScreen() => to(AppRoutes.accountStatementScreen);
//

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
    // debitValue = 0.0;
    // creditValue = 0.0;
  }

  _updateValues(List<MatStatementModel> items) {
    // debitValue = _calculateSum(items: items, type: BondItemType.debtor);
    // creditValue = _calculateSum(items: items, type: BondItemType.creditor);

    totalQuantity = _calculateSum(items);
  }

  int _calculateSum(List<MatStatementModel> items) => items.fold(
        0,
        (sum, item) => sum + (item.quantity ?? 0),
      );

  String get screenTitle => 'حركات ${selectedMat?.matName}';

// // Helper Methods
// static String get _formattedToday => DateTime.now().dayMonthYear;
//
// void _showErrorSnackBar(String title, String message) {
//   Get.snackbar(title, message, icon: const Icon(Icons.error_outline));
// }
//
// void launchBondEntryBondScreen({required BuildContext context, required String originId}) async {
//   EntryBondModel entryBondModel = await read<EntryBondController>().getEntryBondById(entryId: originId);
//
//   if (!context.mounted) return;
//   launchFloatingWindow(
//     context: context,
//     minimizedTitle: 'سند خاص ب ${entryBondModel.origin!.originType!.label}',
//     floatingScreen: EntryBondDetailsScreen(entryBondModel: entryBondModel),
//   );
// }
}
