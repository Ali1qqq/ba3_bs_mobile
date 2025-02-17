import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/widgets/app_button.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/entry_bond/entry_bond_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/grid_column_item.dart';
import '../../data/models/entry_bond_model.dart';
import '../widgets/entry_bond_details/bond_record_data_source.dart';

class EntryBondDetailsScreen extends StatelessWidget {
  const EntryBondDetailsScreen({super.key, required this.entryBondModel});

  final EntryBondModel entryBondModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(AppStrings.date.tr),
            Text(" ${entryBondModel.items!.itemList.first.date}"),
            Spacer(),
            Text(AppStrings.number.tr),
            Text(" ${entryBondModel.items!.docId}"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: SfDataGrid(
            horizontalScrollPhysics: const NeverScrollableScrollPhysics(),
            verticalScrollPhysics: const BouncingScrollPhysics(),
            source: BondDataGridSource(entryBondModel: entryBondModel),
            allowEditing: false,
            selectionMode: SelectionMode.singleDeselect,
            editingGestureType: EditingGestureType.tap,
            navigationMode: GridNavigationMode.cell,
            columnWidthMode: ColumnWidthMode.fill,
            rowHeight: 65,
            allowSwiping: false,
            swipeMaxOffset: 200,
            columns: <GridColumn>[
              gridColumnItem(
                label: AppConstants.account,
                name: AppConstants.rowBondAccount,
                color: Colors.blue,
              ),
              gridColumnItem(
                label: AppStrings.debtor.tr,
                name: AppConstants.rowBondDebitAmount,
                color: Colors.blue,
              ),
              gridColumnItem(
                label: AppStrings.creditor.tr,
                name: AppConstants.rowBondCreditAmount,
                color: Colors.blue,
              ),
              gridColumnItem(
                label: AppStrings.illustration.tr,
                name: AppConstants.rowBondDescription,
                color: Colors.blue,
              ),
            ],
          )),
          AppButton(
            title: AppStrings.viewOrigin.tr,
            onPressed: () {
              read<EntryBondController>().openEntryBondOrigin(entryBondModel, context);
            },
            iconData: Icons.keyboard_return,
          ),
          const VerticalSpace()
        ],
      ),
    );
  }
}