import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/dashboard/controller/cheques_timeline_controller.dart';
import 'package:ba3_bs_mobile/features/dashboard/controller/seller_dashboard_controller.dart';
import 'package:ba3_bs_mobile/features/dashboard/ui/widgets/seller_sale_chart/all_sellers_sales_board.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/bill_profit_dashboard_controller.dart';
import '../../controller/dashboard_layout_controller.dart';
import '../widgets/cheques_chart/cheques_timeline_board.dart';
import '../widgets/dashboard_appbar_widget.dart';
import '../widgets/profit_and_bill_chart/bill_profit_bord.dart';

class DashBoardLayout extends StatelessWidget {
  const DashBoardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<DashboardLayoutController>(builder: (dashboardLayoutController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            // spacing: 10,
            children: [
              DashboardAppBar(controller: dashboardLayoutController),
              VerticalSpace(),

              GetBuilder<SellerDashboardController>(builder: (sellerController) {
                return AllSellersSalesBoard(controller: sellerController);
              }),
              VerticalSpace(20),
              GetBuilder<BillProfitDashboardController>(builder: (billProfitDashboardController) {
                return BillProfitBord(billProfitDashboardController: billProfitDashboardController);
              }),
              VerticalSpace(20),
              GetBuilder<ChequesTimelineController>(builder: (chequesTimelineController) {
                return ChequesTimelineBoard(
                  chequesTimelineController: chequesTimelineController,
                );
              }),
              VerticalSpace(20),
              // OrganizedWidget(
              //     titleWidget: Row(
              //       children: [
              //         Spacer(),
              //         Center(
              //             child: Text(
              //           AppStrings.userAdministration,
              //           style: AppTextStyles.headLineStyle1,
              //         )),
              //         Spacer(),
              //         IconButton(
              //           tooltip: AppStrings.refresh.tr,
              //           icon: Icon(
              //             FontAwesomeIcons.refresh,
              //             color: AppColors.lightBlueColor,
              //           ),
              //           onPressed: dashboardLayoutController.refreshDashBoardUser,
              //         ),
              //         HorizontalSpace(10),
              //       ],
              //     ),
              //     bodyWidget: AllAttendanceScreen()),

              /* VerticalSpace(20),
                 GetBuilder<BillProfitDashboardController>(builder: (userManagementController) {
                return EmployeeCommitmentChart(employees: userManagementController.convertedUsersToEmployees());
              }),
                GetBuilder<UserManagementController>(builder: (userManagementController) {
                return SizedBox(
                  height: 800,
                  child: PlutoGridWithAppBar(
                    title: AppStrings.allUsers.tr,
                    isLoading: userManagementController.isLoading,
                    rowHeight: 60,
                    // appBar: AppBar(
                    //
                    // ),
                    tableSourceModels: userManagementController.filteredAllUsersWithNunTime,
                    onLoaded: (event) {},
                    onSelected: (selectedRow) {
                      final userId = selectedRow.row?.cells[AppConstants.userIdFiled]?.value;
                      userManagementController.userNavigator.navigateToUserDetails(userId);
                    },
                  ),
                );
              })*/
              // BillProfitBord(billProfitDashboardController: controller)
            ],
          ),
        );
      }),
    );
  }
}