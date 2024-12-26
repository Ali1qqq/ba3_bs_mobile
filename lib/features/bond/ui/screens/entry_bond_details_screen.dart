import 'package:ba3_bs_mobile/core/widgets/app_button.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/entry_bond/entry_bond_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: .72.sh,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      headerRowHeight: 60,
                      allowSwiping: false,
                      swipeMaxOffset: 200,
                      columns: <GridColumn>[
                        gridColumnItem(
                          label: 'الحساب',
                          name: AppConstants.rowBondAccount,
                          color: Colors.blue,
                        ),
                        gridColumnItem(
                          label: ' مدين',
                          name: AppConstants.rowBondDebitAmount,
                          color: Colors.blue,
                        ),
                        gridColumnItem(
                          label: ' دائن',
                          name: AppConstants.rowBondCreditAmount,
                          color: Colors.blue,
                        ),
                        gridColumnItem(
                          label: 'البيان',
                          name: AppConstants.rowBondDescription,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: AppButton(
                  title: 'عرض الاصل',
                  width: 150,
                  onPressed: () {
                    read<EntryBondController>().openEntryBondOrigin(entryBondModel, context);
                  },
                  iconData: Icons.keyboard_return,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
