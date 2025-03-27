import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/user_task/ui/widgets/add_task_buttons.dart';
import 'package:ba3_bs_mobile/features/user_task/ui/widgets/add_task_header.dart';
import 'package:ba3_bs_mobile/features/user_task/ui/widgets/add_task_material_select.dart';
import 'package:ba3_bs_mobile/features/user_task/ui/widgets/add_task_user_select.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../bill/ui/widgets/bill_shared/form_field_row.dart';
import '../controller/all_task_controller.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllTaskController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
            title: Text(
          AppStrings.addNewTask.tr,
          style: AppTextStyles.headLineStyle3,
        )),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.taskFormHandler.formKey,
            child: ListView(
              // spacing: 15,
              children: [
                AddTaskHeader(controller: controller),
                FormFieldRow(
                  firstItem: AddTaskUserSelect(
                    controller: controller,
                  ),
                  secondItem: AddTaskMaterialSelected(
                    controller: controller,
                  ),
                ),
                Divider(),
                VerticalSpace(),
                AddTaskButtons(
                  controller: controller,
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}