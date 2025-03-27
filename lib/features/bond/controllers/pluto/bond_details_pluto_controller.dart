import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/i_controllers/i_recodes_pluto_controller.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../accounts/controllers/accounts_controller.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../data/models/pay_item_model.dart';

class BondDetailsPlutoController extends IRecodesPlutoController<PayItem> {
  // Columns and rows
  late List<PlutoColumn> recordsTableColumns = PayItem().toPlutoGridFormat(bondType).keys.toList();

  List<PlutoRow> recordsTableRows = [];

  final BondType bondType;

  String accountGuid = '';

  set setAccountGuid(accGuid) {
    accountGuid = accGuid;
  }

  BondDetailsPlutoController(this.bondType);

  void onMainTableStateManagerChanged(PlutoGridOnChangedEvent event) {
    if (recordsTableStateManager.currentRow == null) return;
    final String field = event.column.field;

    // Handle updates based on the changed column
    _handleColumnUpdate(field);

    safeUpdateUI();
  }

  void _handleColumnUpdate(String columnField) {
    if (columnField == AppConstants.entryCredit) {
      String correctedText = AppServiceUtils.extractNumbersAndCalculate(recordsTableStateManager.currentRow?.cells[columnField]?.value);
      clearFiledInRow(AppConstants.entryDebit);
      updateCellValue(columnField, correctedText);
    } else if (columnField == AppConstants.entryDebit) {
      String correctedText = AppServiceUtils.extractNumbersAndCalculate(recordsTableStateManager.currentRow?.cells[columnField]?.value);
      clearFiledInRow(AppConstants.entryCredit);
      updateCellValue(columnField, correctedText);
    } else if (columnField == AppConstants.entryAccountGuid) {
      setAccount(columnField);
    }
  }

  void clearFiledInRow(String filedName) {
    updateCellValue(filedName, '0');
  }

  void setAccount(String columnField) {
    final query = recordsTableStateManager.currentCell?.value ?? '';
    final accountsController = read<AccountsController>();

    List<AccountModel> searchedAccounts = accountsController.getAccounts(query);
    AccountModel? selectedAccountModel;

    if (searchedAccounts.length == 1) {
      // Single match
      selectedAccountModel = searchedAccounts.first;
      updateCellValue(columnField, selectedAccountModel.accName);
    } else if (searchedAccounts.isEmpty) {
      // No matches
      updateCellValue(columnField, '');
    }
  }

  void safeUpdateUI() => WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then((value) {
        update();
      });

  double calcCreditTotal() {
    double total = 0;
    if (bondType == BondType.paymentVoucher) {
      return calcDebitTotal();
    }

    for (var element in recordsTableStateManager.rows) {
      if (read<AccountsController>().getAccountIdByName(element.toJson()[AppConstants.entryAccountGuid]) != '') {
        total += double.tryParse(element.toJson()[AppConstants.entryCredit] ?? "") ?? 0;
      }
    }

    return total;
  }

  double calcDebitTotal() {
    double total = 0;
    if (bondType == BondType.receiptVoucher) {
      return calcCreditTotal();
    }
    for (var element in recordsTableStateManager.rows) {
      if (read<AccountsController>().getAccountIdByName(element.toJson()[AppConstants.entryAccountGuid]) != '') {
        total += double.tryParse(element.toJson()[AppConstants.entryDebit] ?? "") ?? 0;
      }
    }

    return total;
  }

  generateEntryBond() {}

  @override
  List<PayItem> get generateRecords {
    recordsTableStateManager.setShowLoading(true);
    final accountName = read<AccountsController>().getAccountNameById(accountGuid);
    String accountId = '';

    final payItems = recordsTableStateManager.rows
        .where((row) {
          accountId = read<AccountsController>().getAccountIdByName(row.cells[AppConstants.entryAccountGuid]?.value ?? '');

          return accountId.isNotEmpty;
        })
        .map((row) => _processBondRow(row: row.toJson(), accId: accountId))
        .whereType<PayItem>()
        .toList();

    final oppositeItems = (bondType == BondType.paymentVoucher || bondType == BondType.receiptVoucher)
        ? payItems
            .map((item) {
              return _generateOppositeItem(item, accountName);
            })
            .whereType<PayItem>()
            .toList()
        : [].whereType<PayItem>().toList();

    final allItems = [...payItems, ...oppositeItems];

    recordsTableStateManager.setShowLoading(false);

    return allItems;
  }

  PayItem _generateOppositeItem(PayItem item, String accountName) {
    if (bondType == BondType.paymentVoucher) {
      return item.copyWith(
        entryAccountGuid: accountGuid,
        entryAccountName: accountName,
        entryCredit: item.entryDebit,
        entryDebit: 0,
      );
    } else if (bondType == BondType.receiptVoucher) {
      return item.copyWith(
        entryAccountGuid: accountGuid,
        entryAccountName: accountName,
        entryCredit: 0,
        entryDebit: item.entryCredit,
      );
    }
    throw Exception('Unsupported bond type');
  }

  PayItem? _processBondRow({required Map<String, dynamic> row, required String accId}) {
    return _createBondRecord(row: row, accId: accId);
  }

  // Helper method to create an BondItemModel from a row
  PayItem _createBondRecord({required Map<String, dynamic> row, required String accId}) => PayItem.fromJsonPluto(row: row, accId: accId);

  void updateCellValue(String field, dynamic value) {
    if (recordsTableStateManager.currentRow!.cells[field] != null) {
      recordsTableStateManager.changeCellValue(
        recordsTableStateManager.currentRow!.cells[field]!,
        value,
        callOnChangedEvent: false,
        notify: true,
      );
    }
    safeUpdateUI();
  }

  clearRowIndex(int rowIdx) {
    final rowToRemove = recordsTableStateManager.rows[rowIdx];

    recordsTableStateManager.removeRows([rowToRemove]);
    Get.back();
    update();
  }

  bool checkIfBalancedBond() {
    if (getDefBetweenCreditAndDebt() == 0) {
      return true;
    } else {
      return false;
    }
  }

  double getDefBetweenCreditAndDebt() {
    return calcCreditTotal().toInt() - calcDebitTotal().toInt() * 1.0;
  }

  // State managers
  @override
  PlutoGridStateManager recordsTableStateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  Color color = Colors.red;

  onMainTableLoaded(PlutoGridOnLoadedEvent event) {
    recordsTableStateManager = event.stateManager;
    recordsTableStateManager.setAutoEditing(true);

    final newRows = recordsTableStateManager.getNewRows(count: 30);
    recordsTableStateManager.appendRows(newRows);

    if (recordsTableStateManager.rows.isNotEmpty && recordsTableStateManager.rows.first.cells.length > 1) {
      final secondCell = recordsTableStateManager.rows.first.cells.entries.elementAt(1).value;
      recordsTableStateManager.setCurrentCell(secondCell, 0);
      event.stateManager.setKeepFocus(true);

      // FocusScope.of(event.stateManager.gridFocusNode.context!).requestFocus(event.stateManager.gridFocusNode);
    }
  }

  void onRowSecondaryTap(PlutoGridOnRowSecondaryTapEvent event, BuildContext context) {}

  prepareBondRows(List<PayItem> itemList) {
    recordsTableStateManager.removeAllRows();
    final newRows = recordsTableStateManager.getNewRows(count: 30);

    if (itemList.isNotEmpty) {
      // itemList.removeWhere(
      //   (element) {
      //     return element.entryAccountGuid == accountGuid;
      //   },
      // );
      recordsTableRows = convertRecordsToRows(itemList
          .where(
            (element) => !(element.entryAccountGuid == accountGuid),
          )
          .toList());

      recordsTableStateManager.appendRows(recordsTableRows);
      recordsTableStateManager.appendRows(newRows);
    } else {
      recordsTableRows = [];
      recordsTableStateManager.appendRows(newRows);
    }
  }

  List<PlutoRow> convertRecordsToRows(List<PayItem> records) => records.map((record) {
        final rowData = record.toPlutoGridFormat(bondType);
        final cells = rowData.map((key, value) => MapEntry(key.field, PlutoCell(value: value?.toString() ?? '')));
        return PlutoRow(cells: cells);
      }).toList();
}