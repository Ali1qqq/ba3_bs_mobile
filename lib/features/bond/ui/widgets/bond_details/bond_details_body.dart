import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/get_accounts_by_enter_action.dart';
import '../../../../../core/widgets/pluto_short_cut.dart';
import '../../../../../core/widgets/pluto_with_edite.dart';
import '../../../controllers/bonds/bond_details_controller.dart';
import '../../../controllers/pluto/bond_details_pluto_controller.dart';

class BondDetailsBody extends StatelessWidget {
  const BondDetailsBody(
      {super.key,
      required this.bondTypeModel,
      required this.bondDetailsController,
      required this.bondDetailsPlutoController,
      required this.tag});

  final BondType bondTypeModel;
  final BondDetailsController bondDetailsController;
  final BondDetailsPlutoController bondDetailsPlutoController;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<BondDetailsPlutoController>(
        tag: tag,
        builder: (_) {
          return FocusScope(
            autofocus: true,
            child: PlutoWithEdite(
              columns: bondDetailsPlutoController.recordsTableColumns,
              rows: bondDetailsPlutoController.recordsTableRows,
              onRowSecondaryTap: (PlutoGridOnRowSecondaryTapEvent event) {
                bondDetailsPlutoController.onRowSecondaryTap(event, context);
              },
              onChanged: bondDetailsPlutoController.onMainTableStateManagerChanged,
              onLoaded: bondDetailsPlutoController.onMainTableLoaded,
              shortCut: customPlutoShortcut(GetAccountsByEnterAction(
                  plutoController: bondDetailsPlutoController, context: context, textFieldName: AppConstants.entryAccountGuid)),
              evenRowColor: Color(int.parse("0xff${bondDetailsPlutoController.bondType.color}")),
            ),
          );
        },
      ),
    );
  }
}