import 'package:ba3_bs_mobile/features/bill/controllers/bill/add_bill_controller.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/pluto/add_bill_pluto_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/get_accounts_by_enter_action.dart';
import '../../../../../core/widgets/get_products_by_enter_action.dart';
import '../../../../../core/widgets/pluto_short_cut.dart';
import '../../../../../core/widgets/pluto_with_edite.dart';
import '../../../../patterns/data/models/bill_type_model.dart';
import '../bill_shared/bill_grid_widget.dart';

class AddBillBody extends StatelessWidget {
  const AddBillBody({
    super.key,
    required this.billTypeModel,
    required this.addBillController,
    required this.addBillPlutoController,
    required this.tag,
  });

  final BillTypeModel billTypeModel;
  final AddBillController addBillController;
  final AddBillPlutoController addBillPlutoController;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: GetBuilder<AddBillPlutoController>(
                tag: tag,
                builder: (_) {
                  return FocusScope(
                    autofocus: true,
                    child: PlutoWithEdite(
                      columns: addBillPlutoController.recordsTableColumns,
                      rows: addBillPlutoController.recordsTableRows,
                      onRowSecondaryTap: (PlutoGridOnRowSecondaryTapEvent event) {
                        addBillPlutoController.onMainTableRowSecondaryTap(event, context);
                      },
                      onChanged: addBillPlutoController.onMainTableStateManagerChanged,
                      onLoaded: addBillPlutoController.onMainTableLoaded,
                      shortCut: customPlutoShortcut(GetProductByEnterAction(addBillPlutoController, context)),
                      evenRowColor: Color(billTypeModel.color!),
                    ),
                  );
                }),
          ),
        ),
        const VerticalSpace(5),
        GetBuilder<AddBillPlutoController>(
            tag: tag,
            builder: (_) {
              return Expanded(
                flex: 1,
                child: BillGridWidget(
                  rowColor: Colors.grey,
                  columns: addBillPlutoController.additionsDiscountsColumns,
                  rows: addBillPlutoController.additionsDiscountsRows,
                  onChanged: addBillPlutoController.onAdditionsDiscountsChanged,
                  onLoaded: addBillPlutoController.onAdditionsDiscountsLoaded,
                  shortCut: customPlutoShortcut(GetAccountsByEnterAction(
                      plutoController: addBillPlutoController, textFieldName: AppConstants.id, context: context)),
                ),
              );
            }),
      ],
    );
  }
}
