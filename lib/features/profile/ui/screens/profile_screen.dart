import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/profile/ui/widgets/profile_info_row_shimmer_widget.dart';
import 'package:ba3_bs_mobile/features/profile/ui/widgets/profile_info_row_widget.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/user_target/user_target.dart';
import '../../../../core/widgets/user_target_shimmer_widget.dart';
import '../../../floating_window/services/overlay_service.dart';
import '../../../user_time/ui/widgets/layout_widgets/add_time_widget.dart';
import '../../../user_time/ui/widgets/layout_widgets/holidays_widget.dart';
import '../../../user_time/ui/widgets/layout_widgets/user_daily_time_widget.dart';
import '../../controller/user_time_controller.dart';
import '../widgets/profile_footer.dart';
import '../widgets/task_dialog_strategy.dart';
import '../widgets/task_list_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salesController = read<SellerSalesController>();
    salesController.onSelectSeller(sellerId: read<UserManagementController>().loggedInUserModel?.userSellerId).then(
          (value) => salesController.calculateTotalAccessoriesMobiles(),
        );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Obx(() {
            return salesController.profileScreenState.value == RequestState.loading
                ? ListView(
                    shrinkWrap: true,
                    children: List.generate(
                      10,
                      (index) => Column(
                        children: [
                          ProfileInfoRowShimmerWidget(),
                          VerticalSpace(),
                        ],
                      ),
                    ),
                  )
                : GetBuilder<UserManagementController>(builder: (controller) {
                    return Column(
                      spacing: 10,
                      children: [
                        ProfileInfoRowWidget(
                          label: AppStrings.userName.tr,
                          value: controller.loggedInUserModel!.userName.toString(),
                        ),
                        ProfileInfoRowWidget(
                          label: AppStrings.password.tr,
                          value: controller.loggedInUserModel!.userPassword.toString(),
                        ),
                        ProfileInfoRowWidget(
                          label: AppStrings.totalSales.tr,
                          value: (salesController.totalAccessoriesSales + salesController.totalMobilesSales).toString(),
                        ),
                        AddTimeWidget(
                          userTimeController: read<UserTimeController>(),
                        ),
                        HolidaysWidget(
                          userTimeController: read<UserTimeController>(),
                        ),
                        UserDailyTimeWidget(
                          userModel: read<UserTimeController>().getUserById()!,
                        ),
                        Column(
                          children: [
                            TaskListExpansionTile(
                              taskList: controller.allTaskList,
                              onTap: (task) {
                                OverlayService.showDialog(
                                  height: 460,
                                  context: context,
                                  content: TaskDialogFactory.getStrategy(task.taskType!).buildDialog(task),
                                );
                              },
                              title: AppStrings.tasksTodo.tr,
                            ),
                            SizedBox(height: 10.h),
                            TaskListExpansionTile(
                              taskList: controller.allTaskListDone,
                              onTap: (task) {
                                OverlayService.showDialog(
                                  height: 460,
                                  context: context,
                                  content: TaskDialogFactory.getStrategy(task.taskType!).buildDialog(task),
                                );
                              },
                              title: AppStrings.tasksEnded.tr,
                            ),
                          ],
                        ),

                        /*


                      Spacer(),
                    */
                        Obx(() {
                          return salesController.profileScreenState.value == RequestState.loading
                              ? UserTargetShimmerWidget()
                              : UserTargets(salesController: salesController);
                        }),
                        const ProfileFooter(),
                      ],
                    );
                  });
          }),
        ),
      ),
    );
  }
}