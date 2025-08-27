/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../data/models/account_customer.dart';

class CustomerPlutoEditController extends GetxController {
  CustomerPlutoEditController() {
    getColumns();
  }

  getColumns() {
    Map<PlutoColumn, dynamic> sampleData = AccountCustomer().toPlutoGridFormat();
    columns = sampleData.keys.toList();
    update();
    return columns;
  }

  getRows(List<AccountCustomer> modelList) {
    stateManager.removeAllRows();
    final newRows = stateManager.getNewRows(count: 30);

    if (modelList.isEmpty) {
      stateManager.appendRows(newRows);
      return rows;
    } else {
      rows = modelList.map((model) {
        Map<PlutoColumn, dynamic> rowData = model.toPlutoGridFormat();

        Map<String, PlutoCell> cells = {};

        rowData.forEach((key, value) {
          cells[key.field] = PlutoCell(value: value?.toString() ?? '');
        });

        return PlutoRow(cells: cells);
      }).toList();
    }

    stateManager.appendRows(rows);
    stateManager.appendRows(newRows);
    // print(rows.length);
    return rows;
  }

  List<PlutoRow> rows = [];
  late PlutoGridStateManager stateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());
  List<PlutoColumn> columns = [];

  void updateCellValue(String field, dynamic value) {
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[field]!,
      value,
      callOnChangedEvent: false,
      notify: true,
    );
  }

  List<AccountCustomer> handleSaveAll(String mainId) {
    stateManager.setShowLoading(true);
    List<AccountCustomer> invRecord = [];

    invRecord = stateManager.rows
        .where(
          (element) =>
              element.cells['customerCardNumber']!.value != '' &&
              element.cells['customerAccountName']!.value != '' &&
              element.cells['customerVAT']!.value != '',
        )
        .map(
          (e) => AccountCustomer.fromJsonPluto(e.toJson(), mainId),
        )
        .toList();

    stateManager.setShowLoading(false);
    return invRecord;
  }
}
*/
