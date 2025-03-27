import 'package:ba3_bs_mobile/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/widgets/app_spacer.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../core/widgets/date_picker.dart';
import '../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../bill/ui/widgets/bill_shared/form_field_row.dart';
import '../../../floating_window/services/overlay_service.dart';
import '../../controller/all_task_controller.dart';

class AddTaskHeader extends StatelessWidget {
  final AllTaskController controller;

  const AddTaskHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextAndExpandedChildField(
          label: AppStrings.taskTitle.tr,
          child: CustomTextFieldWithoutIcon(
            textEditingController: controller.taskFormHandler.titleTextEditingController,
            validator: (value) => controller.taskFormHandler.validator(value, 'يرجى إدخال العنوان'),
          ),
        ),
        TextAndExpandedChildField(
          label: AppStrings.materials.tr,
          child: CustomTextFieldWithoutIcon(
            textEditingController: controller.taskFormHandler.materialTextController,
            onSubmitted: (_) async {
              controller.addMaterialToList(context);
            },
          ),
        ),
        FormFieldRow(
          firstItem: Obx(() {
            return TextAndExpandedChildField(
              label: AppStrings.status.tr,
              child: OverlayService.showDropdown<TaskStatus>(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(5),
                ),
                items: TaskStatus.values,
                onChanged: (value) {
                  controller.taskFormHandler.setTaskStatus(value);
                },
                value: controller.taskFormHandler.selectedStatus.value,
                itemLabelBuilder: (TaskStatus item) => item.value,
              ),
            );
          }),
          secondItem: Obx(() {
            return TextAndExpandedChildField(
              label: AppStrings.taskType.tr,
              child: OverlayService.showDropdown<TaskType>(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(5),
                ),
                items: TaskType.values,
                onChanged: (value) {
                  controller.taskFormHandler.setTaskType(value);
                },
                value: controller.taskFormHandler.selectedTaskType.value,
                itemLabelBuilder: (TaskType item) => item.label,
              ),
            );
          }),
        ),
        VerticalSpace(15),
        FormFieldRow(
          firstItem: TextAndExpandedChildField(
            label: AppStrings.lastDateTodo.tr,
            child: Obx(() {
              return DatePicker(
                initDate: controller.taskFormHandler.dueDate.value.dayMonthYear,
                onDateSelected: (date) {
                  controller.taskFormHandler.setDueDate(date);
                },
              );
            }),
          ),
          secondItem: TextAndExpandedChildField(
            label: AppStrings.createdDate.tr,
            child: Obx(() {
              return DatePicker(
                initDate: controller.taskFormHandler.createDate.value.dayMonthYear,
                onDateSelected: (date) {
                  controller.taskFormHandler.setCreateDate(date);
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}