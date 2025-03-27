import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../controller/all_task_controller.dart';

class AddTaskButtons extends StatelessWidget {
  const AddTaskButtons({
    super.key,
    required this.controller,
  });

  final AllTaskController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 15,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!controller.isNewTask)
          AppButton(
            title: AppStrings.delete.tr,
            color: Colors.red,
            onPressed: () {
              controller.deleteTask();
            },
            iconData: FontAwesomeIcons.deleteLeft,
          ),
        AppButton(
          title: controller.isNewTask ? AppStrings.save.tr : AppStrings.edit.tr,
          color: controller.isNewTask ? null : Colors.green,
          onPressed: () {
            controller.saveOrUpdateTask();
          },
          iconData: controller.isNewTask ? FontAwesomeIcons.plusSquare : FontAwesomeIcons.edit,
        ),
      ],
    );
  }
}