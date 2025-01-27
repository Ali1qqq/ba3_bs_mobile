import 'dart:developer';

import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/material_model.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:ba3_bs_mobile/features/tax/data/models/tax_model.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/i_controllers/i_pluto_controller.dart';
import '../../../../core/utils/app_service_utils.dart';
import '../../data/models/discount_addition_account_model.dart';
import '../../data/models/invoice_record_model.dart';
import '../../services/pluto/bill_pluto_calculator.dart';
import '../../services/pluto/bill_pluto_context_menu.dart';
import '../../services/pluto/bill_pluto_grid_service.dart';
import '../../services/pluto/bill_pluto_utils.dart';

class BillDetailsPlutoController extends IPlutoController<InvoiceRecordModel> {
  // Services
  late final BillPlutoGridService _gridService;
  late final BillPlutoCalculator _calculator;
  late final BillPlutoUtils _plutoUtils;
  late final BillPlutoContextMenu _contextMenu;
  final BillTypeModel? billTypeModel;

  BillDetailsPlutoController({this.billTypeModel});

  late List<PlutoColumn> recordsTableColumns;

  // Columns and rows
  // List<PlutoColumn> recordsTableColumns = InvoiceRecordModel().toEditedMap(billTypeModel!).keys.toList();

  late BuildContext context;

  setContext(BuildContext context) {
    this.context = context;
  }

  List<PlutoRow> recordsTableRows = [];

  List<PlutoRow> additionsDiscountsRows = [];

  List<PlutoColumn> additionsDiscountsColumns = AdditionsDiscountsRecordModel().toEditedMap().keys.toList();

  // State managers
  @override
  PlutoGridStateManager recordsTableStateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  @override
  PlutoGridStateManager additionsDiscountsStateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  @override
  String calculateAmountFromRatio(double ratio, double total) => _calculator.calculateAmountFromRatio(ratio, total).toStringAsFixed(2);

  @override
  String calculateRatioFromAmount(double amount, double total) => _calculator.calculateRatioFromAmount(amount, total).toStringAsFixed(2);

  @override
  double get computeWithVatTotal => _calculator.computeWithVatTotal;

  @override
  double get computeBeforeVatTotal => _calculator.computeBeforeVatTotal;

  @override
  double get computeTotalVat => _calculator.computeTotalVat;

  @override
  int get computeGiftsTotal => _calculator.computeGiftsTotal;

  @override
  double get computeGifts => _calculator.computeGifts;

  @override
  double get computeAdditions => _calculator.computeAdditions(_plutoUtils, computeWithVatTotal);

  @override
  double get calculateFinalTotal => _calculator.calculateFinalTotal(_plutoUtils);

  @override
  double get computeDiscounts => _calculator.computeDiscounts(_plutoUtils, computeWithVatTotal);

  @override
  List<InvoiceRecordModel> get generateRecords {
    recordsTableStateManager.setShowLoading(true);

    final materialController = read<MaterialController>();

    final invoiceRecords =
        recordsTableStateManager.rows.map((row) => _processBillRow(row, materialController)).whereType<InvoiceRecordModel>().toList();

    recordsTableStateManager.setShowLoading(false);
    return invoiceRecords;
  }

  Map<Account, List<DiscountAdditionAccountModel>> get generateDiscountsAndAdditions =>
      _gridService.collectDiscountsAndAdditions(_plutoUtils);

  @override
  void moveToNextRow(PlutoGridStateManager stateManager, String cellField) => _gridService.moveToNextRow(stateManager, cellField);

  @override
  void restoreCurrentCell(PlutoGridStateManager stateManager) => _gridService.restoreCurrentCell(stateManager);

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  // Initializer
  void _initializeServices() {
    _gridService = BillPlutoGridService(this);
    _calculator = BillPlutoCalculator(this);
    _plutoUtils = BillPlutoUtils(this);
    _contextMenu = BillPlutoContextMenu(this);

    recordsTableColumns = InvoiceRecordModel().toEditedMap(billTypeModel!).keys.toList();
  }

  onMainTableLoaded(PlutoGridOnLoadedEvent event) {
    recordsTableStateManager = event.stateManager;

    final newRows = recordsTableStateManager.getNewRows(count: 30);
    recordsTableStateManager.appendRows(newRows);

    if (recordsTableStateManager.rows.isNotEmpty && recordsTableStateManager.rows.first.cells.length > 1) {
      final secondCell = recordsTableStateManager.rows.first.cells.entries.elementAt(1).value;
      recordsTableStateManager.setCurrentCell(secondCell, 0);

      FocusScope.of(event.stateManager.gridFocusNode.context!).requestFocus(event.stateManager.gridFocusNode);
    }
  }

  onAdditionsDiscountsLoaded(PlutoGridOnLoadedEvent event) {
    additionsDiscountsStateManager = event.stateManager;

    final newRows = additionsDiscountsStateManager.getNewRows(count: 2);
    additionsDiscountsStateManager.appendRows(newRows);
  }

  void onMainTableStateManagerChanged(PlutoGridOnChangedEvent event) {
    log('onMainTableStateManagerChanged');
    if (recordsTableStateManager.currentRow == null) return;
    final String field = event.column.field;

    // Extract and calculate values
    final quantity = _getQuantity();
    final subTotal = _getSubTotal();
    final total = _getTotal();
    final vat = _getVat();
    final product = _getProduct();

    // Handle updates based on the changed column
    _handleColumnUpdate(field, quantity, subTotal, total, vat, product);

    safeUpdateUI();
  }

  void _handleColumnUpdate(String columnField, int quantity, double subTotal, double total, double vat, String product) {
    if (columnField == AppConstants.invRecSubTotal) {
      _gridService.updateInvoiceValues(subTotal, quantity, billTypeModel!);
    } else if (columnField == AppConstants.invRecTotal) {
      _gridService.updateInvoiceValuesByTotal(total, quantity);
    } else if (columnField == AppConstants.invRecQuantity && quantity > 0) {
      _gridService.updateInvoiceValuesByQuantity(quantity, subTotal, vat);
    } else if (columnField == AppConstants.invRecProduct) {
      _gridService.getProduct(product, recordsTableStateManager, this, context);
    }
    updateAdditionDiscountCell(computeWithVatTotal);
  }

  double _getSubTotal() {
    final subTotalStr = _extractCellValueAsNumber(AppConstants.invRecSubTotal);
    return _plutoUtils.parseExpression(subTotalStr);
  }

  double _getTotal() {
    final totalStr = _extractCellValueAsNumber(AppConstants.invRecTotal);
    return _plutoUtils.parseExpression(totalStr);
  }

  int _getQuantity() {
    final quantityStr = _extractCellValueAsNumber(AppConstants.invRecQuantity);
    return _plutoUtils.parseExpression(quantityStr).toInt();
  }

  double _getVat() {
    final vatStr = _extractCellValueAsNumber(AppConstants.invRecVat);
    return vatStr.toDouble;
  }

  String _getProduct() {
    final product = recordsTableStateManager.currentRow!.cells[AppConstants.invRecProduct]?.value?.toString();
    return product ?? '';
  }

  String _extractCellValueAsNumber(String field) {
    final cellValue = recordsTableStateManager.currentRow!.cells[field]?.value?.toString() ?? '';
    return AppServiceUtils.extractNumbersAndCalculate(cellValue);
  }

  void onMainTableRowSecondaryTap(PlutoGridOnRowSecondaryTapEvent event, BuildContext context) {
    // final materialName = event.row.cells[AppConstants.invRecProduct]?.value;
    // if (materialName == null) return;
    //
    // final materialModel = read<MaterialController>().getMaterialByName(materialName);
    // if (materialModel == null) return;
    //
    // _handleContextMenu(event, materialModel, context);
  }

  // void _handleContextMenu(PlutoGridOnRowSecondaryTapEvent event, MaterialModel materialModel, BuildContext context) {
  //   final field = event.cell.column.field;
  //   if (field == AppConstants.invRecSubTotal) {
  //     _showPriceTypeMenu(event, materialModel, context);
  //   } else if (field == AppConstants.invRecId) {
  //     _showDeleteConfirmationDialog(event, context);
  //   }
  // }

  void _showPriceTypeMenu(event, MaterialModel materialModel, BuildContext context) {
    _contextMenu.showPriceTypeMenu(
        context: context,
        index: event.rowIdx,
        materialModel: materialModel,
        tapPosition: Offset(1, 1),
        invoiceUtils: _plutoUtils,
        gridService: _gridService);
  }

  void _showDeleteConfirmationDialog(event, BuildContext context) => _contextMenu.showDeleteConfirmationDialog(event.rowIdx, context);

  void onAdditionsDiscountsChanged(PlutoGridOnChangedEvent event) {
    log("onAdditionsDiscountsChanged");
    final field = event.column.field;
    final cells = event.row.cells;
    final row = event.row;
    final total = computeWithVatTotal;

    if (total == 0 || !_isRelevantField(field)) return;

    _updateAdditionsDiscountsCells(field, row, cells, total);
    safeUpdateUI();
  }

  bool _isRelevantField(String field) {
    return {
      AppConstants.discount,
      AppConstants.discountRatio,
      AppConstants.addition,
      AppConstants.additionRatio,
    }.contains(field);
  }

  void _updateAdditionsDiscountsCells(String field, PlutoRow row, Map<String, PlutoCell> cells, double total) {
    if (additionsDiscountsStateManager.rows.isEmpty) return;

    final inputValue = _plutoUtils.getCellValueInDouble(cells, field);
    if (inputValue == 0) return;

    final isRatioCell = _isRatioField(field);
    final targetField = _getTargetField(field, isRatioCell);

    final calculateNewValue = isRatioCell ? calculateAmountFromRatio : calculateRatioFromAmount;
    final newValue = calculateNewValue(inputValue, total);

    _gridService.updateAdditionsDiscountsCellValue(row.cells[field]!, inputValue);
    _gridService.updateAdditionsDiscountsCellValue(row.cells[targetField]!, newValue);
  }

  bool _isRatioField(String field) => field == AppConstants.discountRatio || field == AppConstants.additionRatio;

  String _getTargetField(String field, bool isRatioCell) {
    if (isRatioCell) {
      return field == AppConstants.discountRatio ? AppConstants.discount : AppConstants.addition;
    } else {
      return field == AppConstants.discount ? AppConstants.discountRatio : AppConstants.additionRatio;
    }
  }

  void updateAdditionDiscountCell(double total) => _gridService.updateAdditionDiscountCells(total, _plutoUtils);

  InvoiceRecordModel? _processBillRow(PlutoRow row, MaterialController materialController) {
    final materialModel = materialController.getMaterialByName(row.cells[AppConstants.invRecProduct]!.value);

    if (_plutoUtils.isValidItemQuantity(row, AppConstants.invRecQuantity) && materialModel != null) {
      //TODO:
      // change tax ratio guid
      return _createInvoiceRecord(row, materialModel.id!, VatEnums.byGuid(materialModel.matVatGuid ?? "2").taxRatio ?? 0);
    }

    return null;
  }

  // Helper method to create an InvoiceRecordModel from a row
  InvoiceRecordModel _createInvoiceRecord(PlutoRow row, String matId, double matVat) =>
      InvoiceRecordModel.fromJsonPluto(matId, row.toJson(), matVat);

  void prepareBillMaterialsRows(List<InvoiceRecordModel> invRecords) {
    recordsTableStateManager.removeAllRows();

    final newRows = recordsTableStateManager.getNewRows(count: 30);

    if (invRecords.isNotEmpty) {
      recordsTableRows = _gridService.convertRecordsToRows(invRecords, billTypeModel!);

      recordsTableStateManager.appendRows(recordsTableRows);
      recordsTableStateManager.appendRows(newRows);
    } else {
      recordsTableRows = [];
      recordsTableStateManager.appendRows(newRows);
    }
  }

  void prepareAdditionsDiscountsRows(List<Map<String, String>> additionsDiscountsRecords) {
    additionsDiscountsStateManager.removeAllRows();

    if (additionsDiscountsRecords.isNotEmpty) {
      additionsDiscountsRows = _gridService.convertAdditionsDiscountsRecordsToRows(additionsDiscountsRecords);

      additionsDiscountsStateManager.appendRows(additionsDiscountsRows);
    } else {
      additionsDiscountsRows = [];
      additionsDiscountsStateManager.appendRows(_plutoUtils.emptyAdditionsDiscountsRecords());
    }
  }

  void safeUpdateUI() => WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then((value) {
        update();
      });

  void onMainTableRowDoubleTap(PlutoGridOnRowDoubleTapEvent event, BuildContext context) {
    final materialName = event.row.cells[AppConstants.invRecProduct]?.value;
    if (materialName == null) return;

    final materialModel = read<MaterialController>().getMaterialByName(materialName);
    if (materialModel == null) return;

    _handleContextMenu(event, materialModel, context);
  }

  void _handleContextMenu(PlutoGridOnRowDoubleTapEvent event, MaterialModel materialModel, BuildContext context) {
    final field = event.cell.column.field;
    if (field == AppConstants.invRecSubTotal) {
      _showPriceTypeMenu(event, materialModel, context);
    } else if (field == AppConstants.invRecId) {
      _showDeleteConfirmationDialog(event, context);
    }
  }

  @override
  void updateWithSelectedMaterial({
    required MaterialModel? materialModel,
    required PlutoGridStateManager stateManager,
    required IPlutoController plutoController,
  }) =>
      _gridService.updateWithSelectedMaterial(materialModel, stateManager, plutoController);
}

// 530 - 236
