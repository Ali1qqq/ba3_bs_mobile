import 'package:ba3_bs_mobile/features/dashboard/ui/widgets/sheared/box_organize_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/tow_field_row.dart';
import '../../controller/dashboard_layout_controller.dart';
import 'dash_board_accounts/dash_board_account_view_widget.dart';

class DashboardAppBar extends StatelessWidget {
  final DashboardLayoutController controller;

  const DashboardAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        DashBoardAccountViewWidget(
          controller: controller,
        ),
        Spacer(),
        BoxOrganizeWidget(
          primaryColor: Color(0xFF9C27B0),
          secondaryColor: Color(0xFFE040FB),
          titleText: AppStrings.employees.tr,
          childWidget: ListView(
            children: [
              TowFieldRow(
                firstItem: AppStrings.all.tr,
                secondItem: '${controller.allUsersLength}',
              ),
              TowFieldRow(
                firstItem: AppStrings.allUsersMustOnline.tr,
                secondItem: '${controller.usersMustWorkingNowLength}',
              ),
              TowFieldRow(
                firstItem: AppStrings.available.tr,
                secondItem: '${controller.onlineUsersLength}',
              ),
            ],
          ),
        ),
        BoxOrganizeWidget(
          primaryColor: Color(0xFF4196DB),
          secondaryColor: Color(0xFF1CECe5),
          titleText: AppStrings.bills.tr,
          childWidget: ListView(
            children: [
              TowFieldRow(
                firstItem: AppStrings.allBills.tr,
                secondItem: '${controller.allUsers.length}',
              ),
              TowFieldRow(
                firstItem: AppStrings.allBillsDues.tr,
                secondItem: '${controller.allUsers.length}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}