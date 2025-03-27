import 'dart:developer';

import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:ba3_bs_mobile/core/widgets/app_button.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/user_task/controller/all_task_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class AllTaskScreen extends StatelessWidget {
  const AllTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllTaskController>(builder: (controller) {
      return PlutoGridWithAppBar(
        appBar: AppBar(
            centerTitle: true,
            title: Text(
              AppStrings.allTask.tr,
              style: AppTextStyles.headLineStyle2,
            ),
            actions: [
              AppButton(title: AppStrings.addNewTask.tr, onPressed: () => controller.lunchAddTaskScreen(context: context)),
              HorizontalSpace()
            ]),
        title: AppStrings.allTask.tr,
        onLoaded: (e) {},
        onSelected: (event) {
          String userTaskId = event.row?.cells[AppConstants.userTaskIdField]?.value;
          log('userTaskId : $userTaskId');
          controller.lunchAddTaskScreen(context: context, userTaskId: userTaskId);
        },
        isLoading: controller.isTaskLoading,
        tableSourceModels: controller.userTaskList,
      );
    });
  }
}