import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/widgets/pluto_grid_with_app_bar_.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllCheques extends StatelessWidget {
  const AllCheques({super.key, required this.onlyDues});

  final bool onlyDues;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllChequesController>(builder: (logic) {
      return Scaffold(
        body: PlutoGridWithAppBar(
          onLoaded: (p0) {},
          onSelected: (event) {
            String chequesId = event.row?.cells[AppConstants.chequesGuid]?.value;

            logic.openChequesDetailsById(chequesId, context, ChequesType.paidChecks);
          },
          isLoading: logic.isLoading,
          title: !onlyDues ? AppStrings.allCheques.tr : AppStrings.chequesDues.tr,
          tableSourceModels: logic.chequesList.where(
            (element) {
              if (!onlyDues) {
                return true;
              } else {
                return element.isPayed == false;
              }
            },
          ).toList(),
        ),
      );
    });
  }
}