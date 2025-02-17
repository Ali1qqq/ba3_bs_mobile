import 'package:ba3_bs_mobile/core/helper/extensions/entry_bond_model_ectensions.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../data/models/entry_bond_model.dart';

class BondDataGridSource extends DataGridSource {
  final EntryBondModel entryBondModel;

  BondDataGridSource({required this.entryBondModel});

  @override
  List<DataGridRow> get rows => entryBondModel.bondDataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row
          .getCells()
          .map<Widget>((dataGridCell) => Container(
                alignment: dataGridCell.columnName == AppConstants.rowBondDescription ? Alignment.centerRight : Alignment.center,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  textAlign: TextAlign.right,
                  dataGridCell.value == null
                      ? ''
                      : dataGridCell.value is double
                          ? dataGridCell.value.toStringAsFixed(2)
                          : dataGridCell.value.toString(),
                  //     overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
    );
  }

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow, GridSummaryColumn? summaryColumn, RowColumnIndex rowColumnIndex, String summaryValue) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Text(summaryValue),
    );
  }

  @override
  Future<bool> canSubmitCell(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) async {
    return false; // Prevent submission; keep cells editable
  }
}