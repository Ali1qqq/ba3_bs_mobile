import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/widgets/organized_widget.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/ui/widgets/cheques_layout/cheques_layout_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../../core/widgets/general_app_bar_widget.dart';
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
          appBar: generalAppBar(),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: OrganizedWidget(
              titleWidget: Align(
                child: Text(
                  "الشيكات",
                  style: AppTextStyles.headLineStyle2.copyWith(color: AppColors.blueColor),
                ),
              ),
              bodyWidget: Column(
                spacing: 5,
                children: [
                  ChequesTypeItemWidget(text: "إضافة شيك", onPressed:() {
                    controller.openFloatingChequesDetails(context, ChequesType.paidChecks);
                    // Get.to(() => const ChequesDetailsScreen());
                  }),
                  ChequesTypeItemWidget(text: "الشيكات المستحقة", onPressed: () {
                    controller
                      ..fetchAllCheques()
                      ..navigateToChequesScreen(onlyDues:true);

                  }),
                  ChequesTypeItemWidget(text: "معاينة الشيكات",onPressed:  () {
                    controller
                      ..fetchAllCheques()
                      ..navigateToChequesScreen(onlyDues:false);
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
