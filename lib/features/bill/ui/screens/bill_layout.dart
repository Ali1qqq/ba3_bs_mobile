import 'package:ba3_bs_mobile/core/widgets/organized_widget.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/dialogs/loading_dialog.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../widgets/bill_layout/all_bills_types_list.dart';

class BillLayout extends StatelessWidget {
  const BillLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: OrganizedWidget(
                bodyWidget: GetBuilder<AllBillsController>(
                  builder: (controller) => Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AllBillsTypesList(allBillsController: controller),
                      // billLayoutAppBar(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          LoadingDialog(
            isLoading: read<AllBillsController>().getBillsTypesRequestState.value == RequestState.loading,
            message: 'أنواع الفواتير',
            fontSize: 14.sp,
          )
        ],
      ),
    );
  }
}
