import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/utils/app_ui_utils.dart';
import '../../../controller/dashboard_layout_controller.dart';
import 'dashboard_account_shimmer_widget.dart';
import 'dashboard_account_widget.dart';

class DashboardAccountsList extends StatelessWidget {
  final DashboardLayoutController controller;

  const DashboardAccountsList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.fetchDashBoardAccountsRequest.value == RequestState.loading) {
        return SingleChildScrollView(
          child: Wrap(
            spacing: 2.w,
            runSpacing: 6.h,
            children: List.generate(
              10,
                  (index) => const DashBoardAccountShimmerWidget(),
            ),
          ),
        );
      } else {
        return SingleChildScrollView(
          child: Wrap(
            spacing: 2.w,
            runSpacing: 6.h,
            children: List.generate(
              controller.dashBoardAccounts.length,
                  (index) => GestureDetector(
                onSecondaryTap: () => controller.deleteDashboardAccount(index, context),
                child: DashBoardAccountWidget(
                  name: controller.dashboardAccount(index).name.toString(),
                  balance: AppUIUtils.formatDecimalNumberWithCommas(
                    double.parse(controller.dashboardAccount(index).balance.toString()),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    });
  }
}