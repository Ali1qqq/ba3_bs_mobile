import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/i_controllers/i_pluto_controller.dart';

class BondPlutoGridService {
  final IPlutoController controller;

  BondPlutoGridService(
    this.controller,
  );

  PlutoGridStateManager get mainTableStateManager => controller.recordsTableStateManager;

  void updateCellValue(PlutoGridStateManager stateManager, String field, dynamic value) {
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[field]!,
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

  void restoreCurrentCell(PlutoGridStateManager stateManager) {
    final currentCell = stateManager.currentCell;
    if (currentCell != null) {
      stateManager.changeCellValue(
        stateManager.currentRow!.cells[AppConstants.invRecProduct]!,
        currentCell.value,
        callOnChangedEvent: false,
        notify: true,
      );
    }
  }

  void updateBondSelectedRowValues(PlutoRow currentRow, double subTotal, int quantity) {
    final isZeroSubtotal = subTotal == 0;

    final subTotalStr = isZeroSubtotal ? '' : subTotal.toStringAsFixed(2);
    final vat = isZeroSubtotal ? '' : (subTotal * 0.05).toStringAsFixed(2);
    final total = isZeroSubtotal ? '' : ((subTotal + subTotal * 0.05) * quantity).toStringAsFixed(2);

    updateSelectedRowCellValue(mainTableStateManager, currentRow, AppConstants.invRecVat, vat);
    updateSelectedRowCellValue(mainTableStateManager, currentRow, AppConstants.invRecSubTotal, subTotalStr);
    updateSelectedRowCellValue(mainTableStateManager, currentRow, AppConstants.invRecTotal, total);
    updateSelectedRowCellValue(mainTableStateManager, currentRow, AppConstants.invRecQuantity, quantity);
  }

  void updateSelectedRowCellValue(
      PlutoGridStateManager stateManager, PlutoRow currentRow, String field, dynamic value) {
    if (currentRow.cells.containsKey(field)) {
      // Update the cell value in the previous row.
      stateManager.changeCellValue(
        currentRow.cells[field]!,
        value,
        callOnChangedEvent: false,
        notify: true,
        force: true,
      );
    }
  }

/*  List<PlutoRow> convertRecordsToRows(List<EntryBondItemModel> records) => records.map((record) {
        final rowData = record.toPlutoGridFormat();
        final cells = rowData.map((key, value) => MapEntry(key.field, PlutoCell(value: value?.toString() ?? '')));
        return PlutoRow(cells: cells);
      }).toList();*/
}
