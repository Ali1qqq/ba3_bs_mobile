import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/get_accounts_by_enter_action.dart';
import '../../../../../core/widgets/get_products_by_enter_action.dart';
import '../../../../../core/widgets/pluto_short_cut.dart';
import '../../../../../core/widgets/pluto_with_edite.dart';
import '../../../../patterns/data/models/bill_type_model.dart';
import '../../../controllers/bill/bill_details_controller.dart';
import '../../../controllers/pluto/bill_details_pluto_controller.dart';
import '../bill_shared/bill_grid_widget.dart';

class BillDetailsBody extends StatelessWidget {
  const BillDetailsBody({
    super.key,
    required this.billTypeModel,
    required this.billDetailsController,
    required this.billDetailsPlutoController,
    required this.tag,
  });

  final BillTypeModel billTypeModel;
  final BillDetailsController billDetailsController;
  final BillDetailsPlutoController billDetailsPlutoController;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: GetBuilder<BillDetailsPlutoController>(
              tag: tag,
              builder: (_) {
                billDetailsPlutoController.setContext(context);
                return PlutoWithEdite(
                  columns: billDetailsPlutoController.recordsTableColumns,
                  rows: billDetailsPlutoController.recordsTableRows,
                  onRowSecondaryTap: (PlutoGridOnRowSecondaryTapEvent event) {
                    billDetailsPlutoController.onMainTableRowSecondaryTap(event, context);
                  },
                  onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
                    billDetailsPlutoController.onMainTableRowDoubleTap(event, context);
                  },
                  onChanged: billDetailsPlutoController.onMainTableStateManagerChanged,
                  onLoaded: billDetailsPlutoController.onMainTableLoaded,
                  shortCut: customPlutoShortcut(GetProductByEnterAction(billDetailsPlutoController, context)),
                  evenRowColor: Color(billTypeModel.color!),
                );
              }),
        ),
        const VerticalSpace(),
        if (billTypeModel.billPatternType?.hasDiscountsAccount ?? true)
          SizedBox(
            height: 150,
            child: GetBuilder<BillDetailsPlutoController>(
                tag: tag,
                builder: (_) {
                  return BillGridWidget(
                    rowColor: Colors.grey,
                    columns: billDetailsPlutoController.additionsDiscountsColumns,
                    rows: billDetailsPlutoController.additionsDiscountsRows,
                    onChanged: billDetailsPlutoController.onAdditionsDiscountsChanged,
                    onLoaded: billDetailsPlutoController.onAdditionsDiscountsLoaded,
                    shortCut: customPlutoShortcut(GetAccountsByEnterAction(
                      plutoController: billDetailsPlutoController,
                      textFieldName: AppConstants.id,
                      context: context,
                    )),
                  );
                }),
          ),
      ],
    );
  }
}
