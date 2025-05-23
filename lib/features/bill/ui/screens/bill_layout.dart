import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/core/widgets/organized_widget.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/dialogs/loading_dialog.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../users_management/data/models/role_model.dart';
import '../widgets/bill_layout/all_bills_types_list.dart';

class BillLayout extends StatelessWidget {
  const BillLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final allBillsController = read<AllBillsController>();
    return RefreshIndicator(
      onRefresh: allBillsController.refreshBillsTypes,
      child: Obx(() {
        final progress = allBillsController.uploadProgress.value;

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: AppColors.lightBlueColor,
                  ),
                  onPressed: allBillsController.refreshBillsTypes,
                ),
                actions: [
                  if (RoleItemType.administrator.hasAdminPermission)
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: AppButton(
                        title: AppStrings.downloadBills.tr,
                        onPressed: () => allBillsController.fetchAllBillsFromLocal(),
                      ),
                    ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: OrganizedWidget(
                    bodyWidget: GetBuilder<AllBillsController>(
                      builder: (controller) => Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AllBillsTypesList(allBillsController: controller),
                          //    if (RoleItemType.viewBill.hasAdminPermission) billLayoutAppBar(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            LoadingDialog(
              isLoading: allBillsController.saveAllBillsRequestState.value == RequestState.loading,
              message: '${(progress * 100).toStringAsFixed(2)}% من الفواتير',
              fontSize: 14.sp,
            ),
            LoadingDialog(
              isLoading: allBillsController.saveAllBillsBondRequestState.value == RequestState.loading,
              message: '${(progress * 100).toStringAsFixed(2)}% من سندات الفواتير',
              fontSize: 14.sp,
            ),
          ],
        );
      }),
    );
  }
}