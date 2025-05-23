import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/widgets/organized_widget.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/ui/widgets/cheques_layout/cheques_layout_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_style.dart';
import '../widgets/cheques_layout/cheques_type_item_widget.dart';

class ChequeLayout extends StatefulWidget {
  const ChequeLayout({super.key});

  @override
  State<ChequeLayout> createState() => _ChequeLayoutState();
}

class _ChequeLayoutState extends State<ChequeLayout> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetBuilder<AllChequesController>(builder: (controller) {
        return Scaffold(
          appBar: chequesLayoutAppBar(),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: OrganizedWidget(
              titleWidget: Align(
                child: Text(
                  AppStrings.cheques.tr,
                  style: AppTextStyles.headLineStyle2.copyWith(color: AppColors.blueColor),
                ),
              ),
              bodyWidget: Column(
                spacing: 5,
                children: [
                  ChequesTypeItemWidget(
                      text: AppStrings.addCheques.tr,
                      onPressed: () {
                        controller.openFloatingChequesDetails(context, ChequesType.paidChecks, withFetched: true);
                        // Get.to(() => const ChequesDetailsScreen());
                      }),
                  ChequesTypeItemWidget(
                      text: AppStrings.chequesDues.tr,
                      onPressed: () {
                        controller
                          ..fetchAllChequesByType(ChequesType.paidChecks)
                          ..navigateToChequesScreen(onlyDues: true, context: context);
                      }),
                  ChequesTypeItemWidget(
                      text: AppStrings.viewCheques.tr,
                      onPressed: () {
                        controller
                          ..fetchAllChequesByType(ChequesType.paidChecks)
                          ..navigateToChequesScreen(onlyDues: false, context: context);
                      }),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}