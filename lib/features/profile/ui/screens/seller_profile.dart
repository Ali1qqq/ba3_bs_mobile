import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/core/widgets/pluto_grid_with_app_bar_.dart';
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
import '../widgets/task_dialog_strategy.dart';
import '../widgets/task_list_widget.dart';

class SellerProfile extends StatelessWidget {
  const SellerProfile({super.key});

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
                ? SizedBox(
                    height: 1.sh,
                    width: 1.sw,
                    child: ListView(
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
                    ),
                  )
                : GetBuilder<UserManagementController>(builder: (controller) {
                    return Column(
                      spacing: 10,
                      children: [
                        ProfileInfoRowWidget(
                          label: AppStrings.totalSales.tr,
                          value: (salesController.totalAccessoriesSales + salesController.totalMobilesSales).toString(),
                        ),
                        ProfileInfoRowWidget(
                          label: AppStrings.groupForTarget.tr,
                          value: controller.loggedInUserModel!.hasGroupTarget
                              ? controller.loggedInUserModel!.groupForTarget!.groupName
                              : 'لا يوجد',
                        ),
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

                        /*


                      Spacer(),
                    */
                        Obx(() {
                          return salesController.profileScreenState.value == RequestState.loading
                              ? UserTargetShimmerWidget()
                              : UserTargets(salesController: salesController);
                        }),
                        SizedBox(
                          height: 0.5.sh,
                          child: PlutoGridWithAppBar(
                            // title: '${AppStrings.bills.tr} ${controller.selectedSeller!.costName}',
                            onLoaded: (e) {
                              e.stateManager.sortDescending(e.stateManager.columns[2]);
                            },
                            onSelected: (event) {},
                            isLoading: controller.isLoading,
                            tableSourceModels: salesController.sellerSales,
                          ),
                        ),
                        /*       AppButton(
                          title: AppStrings.viewSales,
                          onPressed: () {
                            salesController.launchSellerSalesScreen(context);
                          },
                          fontSize: 16,
                          width: 1.sw,
                          iconData: FontAwesomeIcons.fileInvoice,
                        ),*/
                      ],
                    );
                  });
          }),
        ),
      ),
    );
  }
}