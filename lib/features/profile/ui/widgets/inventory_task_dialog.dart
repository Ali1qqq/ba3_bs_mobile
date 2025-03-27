import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/task_status_extension.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/features/user_task/data/model/user_task_model.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../../core/widgets/app_button.dart';

class InventoryTaskDialog extends StatelessWidget {
  final UserTaskModel task;

  const InventoryTaskDialog({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserManagementController>(builder: (controller) {
      return Column(
        children: [
          Container(
            height: 400,
            color: Colors.white,
            alignment: Alignment.center,
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              itemCount: task.materialTask!.length,
              itemBuilder: (context, materialIndex) {
                return ListTile(
                  title: Text(
                    task.materialTask![materialIndex].materialName!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${AppStrings.identificationNumber.tr}: ${task.materialTask![materialIndex].docId}",
                      style: TextStyle(color: Colors.grey)),
                  leading: Icon(Icons.inventory),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        " ${AppStrings.quantity.tr} \n ${task.materialTask![materialIndex].quantity}",
                        style: AppTextStyles.headLineStyle4,
                        textAlign: TextAlign.center,
                      ),
                      VerticalDivider(),
                      task.status.isFinished
                          ? Text(
                              " ${AppStrings.quantityInTask.tr} \n ${task.materialTask![materialIndex].quantityInTask}",
                              style: AppTextStyles.headLineStyle4,
                              textAlign: TextAlign.center,
                            )
                          : SizedBox(
                              width: 50,
                              height: 30,
                              child: TextField(
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    task.materialTask![materialIndex].quantityInTask =
                                        AppServiceUtils.extractNumbersAndCalculate(value).toDouble.toInt();
                                  }
                                },
                                decoration: InputDecoration(
                                  enabled: task.status.isInProgress,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (!task.status.isFinished)
            AppButton(
              title: task.status.isInProgress ? AppStrings.save.tr : AppStrings.start,
              onPressed: () {
                controller.updateInventoryTask(task: task);
                task.status = task.status.isInProgress ? TaskStatus.done : TaskStatus.inProgress;
              },
            )
        ],
      );
    });
  }
}