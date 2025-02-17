import 'package:ba3_bs_mobile/features/bond/data/models/entry_bond_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../constants/app_constants.dart';
import '../enums/enums.dart';

extension EntryBondModelExtension on EntryBondModel {
  // Build DataGrid rows based on bond model
  List<DataGridRow> get bondDataGridRows =>
      items?.itemList.map<DataGridRow>((bondItem) {
        return DataGridRow(cells: [
          DataGridCell<String>(columnName: AppConstants.rowBondAccount, value: bondItem.account.name),
          DataGridCell<double>(
            columnName: AppConstants.rowBondDebitAmount,
            value: bondItem.bondItemType == BondItemType.debtor ? bondItem.amount : 0.0,
          ),
          DataGridCell<double>(
            columnName: AppConstants.rowBondCreditAmount,
            value: bondItem.bondItemType == BondItemType.creditor ? bondItem.amount : 0.0,
          ),
          DataGridCell<String>(columnName: AppConstants.rowBondDescription, value: '${bondItem.note}'),
        ]);
      }).toList() ??
      [];
}