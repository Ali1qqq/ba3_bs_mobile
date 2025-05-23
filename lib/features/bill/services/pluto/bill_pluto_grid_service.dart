import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/dialogs/product_selection_dialog_content.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/i_controllers/i_pluto_controller.dart';
import '../../../../core/utils/app_service_utils.dart';
import '../../../accounts/controllers/accounts_controller.dart';
import '../../../floating_window/services/overlay_service.dart';
import '../../../materials/data/models/materials/material_model.dart';
import '../../data/models/discount_addition_account_model.dart';
import '../../data/models/invoice_record_model.dart';
import 'bill_pluto_utils.dart';

class BillPlutoGridService {
  final IPlutoController controller;

  BillPlutoGridService(this.controller);

  PlutoGridStateManager get mainTableStateManager => controller.recordsTableStateManager;

  PlutoGridStateManager get additionsDiscountsStateManager => controller.additionsDiscountsStateManager;

  void updateCellValue(PlutoGridStateManager stateManager, String field, dynamic value) {
    log('hi');
    log(field);
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[field]!,
      value,
      callOnChangedEvent: false,
      notify: true,
      force: true,
    );
  }

  void updateAdditionsDiscountsCellValue(PlutoCell cell, dynamic value) {
    additionsDiscountsStateManager.changeCellValue(
      cell,
      value,
      callOnChangedEvent: false,
      notify: true,
      force: true,
    );
  }

  void moveToNextRow(PlutoGridStateManager stateManager, String cellField) {
    final currentRowIdx = stateManager.currentRowIdx;

    if (currentRowIdx != null && currentRowIdx < stateManager.rows.length - 1) {
      stateManager.setCurrentCell(
        stateManager.rows[currentRowIdx + 1].cells[cellField],
        currentRowIdx + 1,
      );
    }
  }

  void restoreCurrentCell(PlutoGridStateManager stateManager, BillTypeModel billTypeModel) {
    _clearRowValues(stateManager, billTypeModel);

    // final currentCell = stateManager.currentCell;
    // if (currentCell != null) {
    //   stateManager.changeCellValue(
    //     stateManager.currentRow!.cells[AppConstants.invRecProduct]!,
    //     currentCell.value,
    //     callOnChangedEvent: false,
    //     notify: true,
    //   );
    // }
  }

  void updateInvoiceValuesByQuantity(int quantity, double subtotal, double vat, BillTypeModel billTypeModel) {
    // Check if the material exists, otherwise clear all values
    if (!isMaterialExisting(mainTableStateManager)) {
      _clearRowValues(mainTableStateManager, billTypeModel);
      return;
    }

    final isZeroSubtotal = subtotal == 0 || quantity == 0;

    final total = isZeroSubtotal ? '' : ((subtotal + vat) * quantity).toStringAsFixed(2);

    updateCellValue(mainTableStateManager, AppConstants.invRecQuantity, quantity);
    updateCellValue(mainTableStateManager, AppConstants.invRecTotal, total);
  }

  void updateInvoiceValues(double subTotal, int quantity, BillTypeModel billTypeModel) {
    // Check if the material exists, otherwise clear all values
    if (!isMaterialExisting(mainTableStateManager)) {
      _clearRowValues(mainTableStateManager, billTypeModel);
      return;
    }

    final isZeroSubtotal = subTotal == 0;

    final subTotalStr = isZeroSubtotal ? '' : subTotal.toStringAsFixed(2);
    final vat = isZeroSubtotal || (!billTypeModel.billPatternType!.hasVat) ? '' : (subTotal * 0.05).toStringAsFixed(2);
    final total = isZeroSubtotal
        ? ''
        : billTypeModel.billPatternType!.hasVat
            ? ((subTotal + subTotal * 0.05) * quantity).toStringAsFixed(2)
            : (subTotal * quantity).toStringAsFixed(2);

    if (billTypeModel.billPatternType!.hasVat) {
      updateCellValue(mainTableStateManager, AppConstants.invRecVat, vat);
      updateCellValue(mainTableStateManager, AppConstants.invRecSubTotalWithVat, (subTotalStr.toDouble + vat.toDouble).toStringAsFixed(2));
    }

    updateCellValue(mainTableStateManager, AppConstants.invRecSubTotal, subTotalStr);
    updateCellValue(mainTableStateManager, AppConstants.invRecTotal, total);
    updateCellValue(mainTableStateManager, AppConstants.invRecQuantity, quantity);
  }

  void updateInvoiceValuesByTotal(double total, int quantity, BillTypeModel billTypeModel) {
    // Check if the material exists, otherwise clear all values
    if (!isMaterialExisting(mainTableStateManager)) {
      _clearRowValues(mainTableStateManager, billTypeModel);
      return;
    }

    final isZeroTotal = total == 0 || quantity == 0;

    final subTotalStr = isZeroTotal ? '' : (total / (quantity * 1.05)).toStringAsFixed(2);
    final vat = isZeroTotal ? '' : ((total / (quantity * 1.05)) * 0.05).toStringAsFixed(2);

    final totalStr = isZeroTotal ? '' : total.toStringAsFixed(2);

    updateCellValue(mainTableStateManager, AppConstants.invRecSubTotal, subTotalStr);
    updateCellValue(mainTableStateManager, AppConstants.invRecTotal, totalStr);
    if (billTypeModel.billPatternType!.hasVat) {
      updateCellValue(mainTableStateManager, AppConstants.invRecVat, vat);

      updateCellValue(mainTableStateManager, AppConstants.invRecSubTotalWithVat, (subTotalStr.toDouble + vat.toDouble).toStringAsFixed(2));
    }
  }

  void updateInvoiceValuesBySubTotalWithVat(double subTotalStr, int quantity, BillTypeModel billTypeModel) {
    // Check if the material exists, otherwise clear all values
    if (!isMaterialExisting(mainTableStateManager)) {
      _clearRowValues(mainTableStateManager, billTypeModel);
      return;
    }

    final isZeroTotal = subTotalStr == 0 || quantity == 0;

    final vat = isZeroTotal ? '' : ((subTotalStr / 1.05) * 0.05).toStringAsFixed(2);
    final subTotal = isZeroTotal ? '' : (subTotalStr - vat.toDouble).toStringAsFixed(2);

    final totalStr = isZeroTotal ? '' : (subTotalStr * quantity).toStringAsFixed(2);

    updateCellValue(mainTableStateManager, AppConstants.invRecSubTotal, subTotal);
    updateCellValue(mainTableStateManager, AppConstants.invRecTotal, totalStr);
    if (billTypeModel.billPatternType!.hasVat) {
      updateCellValue(mainTableStateManager, AppConstants.invRecVat, vat);

      updateCellValue(mainTableStateManager, AppConstants.invRecSubTotalWithVat, subTotalStr);
    }
  }

  void updateInvoiceValuesBySubTotal(
      {required PlutoRow selectedRow, required double subTotal, required int quantity, required BillTypeModel billTypeModel}) {
    final isZeroSubtotal = subTotal == 0;

    final subTotalStr = isZeroSubtotal ? '' : subTotal.toStringAsFixed(2);
    final vat = isZeroSubtotal ? '' : (subTotal * 0.05).toStringAsFixed(2);
    final total = isZeroSubtotal ? '' : ((subTotal + subTotal * 0.05) * quantity).toStringAsFixed(2);
    if (billTypeModel.billPatternType!.hasVat) {
      updateSelectedRowCellValue(mainTableStateManager, selectedRow, AppConstants.invRecVat, vat);
      updateSelectedRowCellValue(
          mainTableStateManager, selectedRow, AppConstants.invRecSubTotalWithVat, (subTotalStr.toDouble + vat.toDouble).toStringAsFixed(2));
    }
    updateSelectedRowCellValue(mainTableStateManager, selectedRow, AppConstants.invRecSubTotal, subTotalStr);
    updateSelectedRowCellValue(mainTableStateManager, selectedRow, AppConstants.invRecTotal, total);
    updateSelectedRowCellValue(mainTableStateManager, selectedRow, AppConstants.invRecQuantity, quantity);
  }

  void _clearRowValues(PlutoGridStateManager stateManager, BillTypeModel billTypeModel) {
    if (billTypeModel.billPatternType!.hasVat) {
      updateCellValue(stateManager, AppConstants.invRecVat, '');
      updateCellValue(stateManager, AppConstants.invRecSubTotalWithVat, '');
    }

    updateCellValue(stateManager, AppConstants.invRecProduct, '');
    updateCellValue(stateManager, AppConstants.invRecSubTotal, '');
    updateCellValue(stateManager, AppConstants.invRecTotal, '');
    updateCellValue(stateManager, AppConstants.invRecQuantity, '');
  }

  bool isMaterialExisting(PlutoGridStateManager stateManager) =>
      read<MaterialController>().doesMaterialExist(stateManager.currentRow!.cells[AppConstants.invRecProduct]!.value);

  void updateSelectedRowCellValue(PlutoGridStateManager stateManager, PlutoRow selectedRow, String field, dynamic value) {
    if (selectedRow.cells.containsKey(field)) {
      // Update the cell value in the previous row.
      stateManager.changeCellValue(
        selectedRow.cells[field]!,
        value,
        callOnChangedEvent: false,
        notify: true,
        force: true,
      );
    }
  }

  void updateAdditionDiscountCells(double total, BillPlutoUtils invoiceUtils) {
    if (additionsDiscountsStateManager.rows.isEmpty) return;

    for (final row in additionsDiscountsStateManager.rows) {
      // Update both discount and addition cells based on the total value
      final fields = [AppConstants.discount, AppConstants.addition];

      for (final field in fields) {
        total == 0 ? updateAdditionsDiscountsCellValue(row.cells[field]!, '') : _updateCell(field, row, total, invoiceUtils);
      }
    }
  }

  void _updateCell(String field, PlutoRow row, double total, BillPlutoUtils plutoUtils) {
    final ratio = plutoUtils.getCellValueInDouble(row.cells, _getTargetField(field));

    final newValue = ratio == 0 ? '' : controller.calculateAmountFromRatio(ratio, total);

    final valueCell = row.cells[field]!;

    updateAdditionsDiscountsCellValue(valueCell, newValue);
  }

  String _getTargetField(String field) => field == AppConstants.discount ? AppConstants.discountRatio : AppConstants.additionRatio;

  List<PlutoRow> convertRecordsToRows(List<InvoiceRecordModel> records, BillTypeModel billTypeModel) => records.map((record) {
        final rowData = record.toEditedMap(billTypeModel);
        final cells = rowData.map((key, value) => MapEntry(key.field, PlutoCell(value: value?.toString() ?? '')));
        return PlutoRow(cells: cells);
      }).toList();

  List<PlutoRow> convertAdditionsDiscountsRecordsToRows(List<Map<String, String>> additionsDiscountsRecords) =>
      additionsDiscountsRecords.map((record) {
        final cells = {
          AppConstants.id: PlutoCell(value: record[AppConstants.id] ?? ''),
          AppConstants.discount: PlutoCell(value: record[AppConstants.discount] ?? ''),
          AppConstants.discountRatio: PlutoCell(value: record[AppConstants.discountRatio] ?? ''),
          AppConstants.addition: PlutoCell(value: record[AppConstants.addition] ?? ''),
          AppConstants.additionRatio: PlutoCell(value: record[AppConstants.additionRatio] ?? ''),
        };
        return PlutoRow(cells: cells);
      }).toList();

  Map<Account, List<DiscountAdditionAccountModel>> collectDiscountsAndAdditions(BillPlutoUtils plutoUtils) {
    final accounts = <Account, List<DiscountAdditionAccountModel>>{};
    final accountsController = read<AccountsController>();

    for (final row in additionsDiscountsStateManager.rows) {
      final discountData = _extractDiscountData(plutoUtils, row);
      final additionData = _extractAdditionData(plutoUtils, row);

      if (discountData.isValid || additionData.isValid) {
        final accountName = row.cells[AppConstants.id]?.value ?? '';
        final accountId = accountsController.getAccountIdByName(accountName);

        if (_isValidAccount(accountName, accountId)) {
          final accountModel = _createAccountModel(
            accountName: accountName,
            accountId: accountId,
            discountData: discountData,
            additionData: additionData,
          );

          _updateAccountsMap(accounts, discountData, additionData, accountModel);
        }
      }
    }

    return accounts;
  }

// Helper method to extract discount data
  DiscountData _extractDiscountData(BillPlutoUtils plutoUtils, PlutoRow row) => DiscountData(
        percentage: plutoUtils.getCellValueInDouble(row.cells, AppConstants.discountRatio),
        value: plutoUtils.getCellValueInDouble(row.cells, AppConstants.discount),
      );

// Helper method to extract addition data
  AdditionData _extractAdditionData(BillPlutoUtils plutoUtils, PlutoRow row) => AdditionData(
        percentage: plutoUtils.getCellValueInDouble(row.cells, AppConstants.additionRatio),
        value: plutoUtils.getCellValueInDouble(row.cells, AppConstants.addition),
      );

// Helper method to check if account data is valid
  bool _isValidAccount(String accountName, String accountId) => accountName.isNotEmpty && accountId.isNotEmpty;

// Helper method to create the DiscountAdditionAccountModel
  DiscountAdditionAccountModel _createAccountModel({
    required String accountName,
    required String accountId,
    required DiscountData discountData,
    required AdditionData additionData,
  }) =>
      DiscountAdditionAccountModel(
        accName: accountName,
        id: accountId,
        amount: discountData.isValid ? discountData.value : additionData.value,
        percentage: discountData.isValid ? discountData.percentage : additionData.percentage,
      );

// Helper method to update the accounts map
  void _updateAccountsMap(
    Map<Account, List<DiscountAdditionAccountModel>> accounts,
    DiscountData discountData,
    AdditionData additionData,
    DiscountAdditionAccountModel accountModel,
  ) {
    final accountType = discountData.isValid ? BillAccounts.discounts : BillAccounts.additions;

    if (accounts.containsKey(accountType)) {
      accounts[accountType]?.add(accountModel);
    } else {
      accounts[accountType] = [accountModel];
    }
  }

  void getProduct(String productText, PlutoGridStateManager stateManager, IPlutoController plutoController, BuildContext context,
      BillTypeModel billTypeModel) async {
    // Initialize variables

    final productTextController = TextEditingController()..text = productText;
    final materialController = read<MaterialController>();

    // Search for matching materials
    var searchedMaterials = materialController.searchOfProductByText(productText);
    MaterialModel? selectedMaterial;

    if (searchedMaterials.length == 1) {
      // Single match
      selectedMaterial = searchedMaterials.first;
      updateWithSelectedMaterial(selectedMaterial, stateManager, plutoController, billTypeModel);
    } else if (searchedMaterials.isEmpty) {
      // No matches
      updateWithSelectedMaterial(null, stateManager, plutoController, billTypeModel);
    } else {
      if (!context.mounted) return;
      // Clear focus from PlutoWithEdite before showing the dialog
      FocusScope.of(context).unfocus();

      // Multiple matches, show search dialog
      _showSearchDialog(
          context: context,
          productTextController: productTextController,
          searchedMaterials: searchedMaterials,
          materialController: materialController,
          stateManager: stateManager,
          plutoController: plutoController,
          billTypeModel: billTypeModel);
    }
  }

  void _showSearchDialog(
      {required TextEditingController productTextController,
      required List<MaterialModel> searchedMaterials,
      required MaterialController materialController,
      required PlutoGridStateManager stateManager,
      required IPlutoController plutoController,
      required BillTypeModel billTypeModel,
      required BuildContext context}) {
    OverlayService.showDialog(
      context: context,
      height: 1.sh,
      width: .8.sw,
      content: ProductSelectionDialogContent(
        searchedMaterials: searchedMaterials,
        onRowSelected: (PlutoGridOnSelectedEvent onSelectedEvent) {
          final materialId = onSelectedEvent.row?.cells[AppConstants.materialIdFiled]?.value;

          final selectedMaterial = materialId != null ? materialController.getMaterialById(materialId) : null;

          updateWithSelectedMaterial(selectedMaterial, stateManager, plutoController, billTypeModel);

          OverlayService.back();
        },
        onSubmitted: (_) async {
          searchedMaterials = materialController.searchOfProductByText(productTextController.text);
          materialController.update();
        },
        productTextController: productTextController,
      ),
      onCloseCallback: () {
        log('Product Selection Dialog Closed.');
      },
    );
  }

  void updateWithSelectedMaterial(
      MaterialModel? materialModel, PlutoGridStateManager stateManager, IPlutoController plutoController, BillTypeModel billTypeModel) {
    if (materialModel != null) {
      _updateRowWithMaterial(materialModel, stateManager, billTypeModel);
      plutoController.moveToNextRow(stateManager, AppConstants.invRecProduct);
    } else {
      plutoController.restoreCurrentCell(stateManager);
    }

    stateManager.notifyListeners();
    plutoController.update();
  }

  void _updateRowWithMaterial(MaterialModel materialModel, PlutoGridStateManager stateManager, BillTypeModel billTypeModel) {
    final subTotal = materialModel.endUserPrice?.toDouble ?? 0;

    final isZeroSubtotal = subTotal == 0;

    final vat = isZeroSubtotal ? '' : (subTotal * 0.05).toStringAsFixed(2);
    final total = isZeroSubtotal ? '' : ((subTotal + subTotal * 0.05) * 1).toStringAsFixed(2);

    updateCellValue(stateManager, AppConstants.invRecProduct, materialModel.matName);
    updateCellValue(stateManager, AppConstants.invRecSubTotal, subTotal);
    updateCellValue(stateManager, AppConstants.invRecQuantity, 1);
    if (billTypeModel.billPatternType!.hasVat) {
      updateCellValue(mainTableStateManager, AppConstants.invRecVat, vat);
    }
    updateCellValue(stateManager, AppConstants.invRecTotal, total);
  }

  void returnVatAndAddedToSubTotal(PlutoGridStateManager recordsTableStateManager, BillTypeModel billTypeModel) {
    for (var row in mainTableStateManager.rows) {
      if ((row.cells[AppConstants.invRecProduct]?.value) == '') {
        return;
      }
      final quantity = AppServiceUtils.parseInt(row.cells[AppConstants.invRecQuantity]?.value);
      final subTotal = AppServiceUtils.parseDouble(row.cells[AppConstants.invRecSubTotal]?.value);
      final vat = AppServiceUtils.parseDouble(row.cells[AppConstants.invRecVat]?.value);
      if (vat == 0) {
        updateInvoiceValuesBySubTotalWithRow(subTotal, quantity, billTypeModel, false, row);
      }
    }
  }

  clearAllVatAndAddedToSubTotal(PlutoGridStateManager stateManager, BillTypeModel billTypeModel) {
    for (var row in mainTableStateManager.rows) {
      if ((row.cells[AppConstants.invRecProduct]?.value) == '') {
        return;
      }
      final quantity = AppServiceUtils.parseInt(row.cells[AppConstants.invRecQuantity]?.value);
      final subTotalWithVatCell = AppServiceUtils.parseDouble(row.cells[AppConstants.invRecSubTotalWithVat]?.value);
      updateInvoiceValuesBySubTotalWithRow(subTotalWithVatCell, quantity, billTypeModel, true, row);
    }
  }

  void updateInvoiceValuesBySubTotalWithRow(
    double subTotalValue,
    int quantity,
    BillTypeModel billTypeModel,
    bool isPurchaseWithoutVat,
    PlutoRow currentRow,
  ) {
    final bool isZeroTotal = subTotalValue == 0 || quantity == 0;

    final String vat = _calculateVat(subTotalValue, isZeroTotal, isPurchaseWithoutVat);
    final String subTotal = isZeroTotal ? '' : (subTotalValue - double.parse(vat)).toStringAsFixed(2);
    final String totalStr = isZeroTotal ? '' : (subTotalValue * quantity).toStringAsFixed(2);

    _updateCellValueByRow(currentRow, AppConstants.invRecSubTotal, subTotal);
    _updateCellValueByRow(currentRow, AppConstants.invRecTotal, totalStr);

    if (billTypeModel.billPatternType?.hasVat == true) {
      _updateCellValueByRow(currentRow, AppConstants.invRecVat, vat);
      _updateCellValueByRow(
        currentRow,
        AppConstants.invRecSubTotalWithVat,
        subTotalValue.toStringAsFixed(2),
      );
    }
  }

  String _calculateVat(
    double subTotalValue,
    bool isZeroTotal,
    bool isPurchaseWithoutVat,
  ) {
    if (isZeroTotal) return '';
    if (isPurchaseWithoutVat) return '0';
    return ((subTotalValue / 1.05) * 0.05).toStringAsFixed(2);
  }

  void _updateCellValueByRow(PlutoRow row, String cellKey, String value) {
    mainTableStateManager.changeCellValue(
      row.cells[cellKey]!,
      value,
      callOnChangedEvent: false,
      notify: true,
      force: true,
    );
  }
}

// Data class for discount data
class DiscountData {
  final double percentage;
  final double value;

  bool get isValid => percentage > 0;

  DiscountData({required this.percentage, required this.value});
}

// Data class for addition data
class AdditionData {
  final double percentage;
  final double value;

  bool get isValid => percentage > 0;

  AdditionData({required this.percentage, required this.value});
}