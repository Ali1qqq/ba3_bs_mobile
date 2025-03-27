import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/features/user_task/data/model/user_task_model.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../floating_window/services/overlay_service.dart';

class SaleTaskDialog extends StatelessWidget {
  final UserTaskModel task;

  const SaleTaskDialog({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
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
                    FutureBuilder<int>(
                      future: read<UserManagementController>().getCurrentUserMaterialsSales(
                          materialId: task.materialTask![materialIndex].docId!, startDay: task.dueDate!, endDay: task.createdAt!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            "${AppStrings.sold.tr} \n ...",
                            style: AppTextStyles.headLineStyle4,
                            textAlign: TextAlign.center,
                          );
                        } else if (snapshot.hasError) {
                          log(snapshot.error.toString());
                          return Text(
                            "${AppStrings.sold.tr} \n ❌ ",
                            style: AppTextStyles.headLineStyle4,
                            textAlign: TextAlign.center,
                          );
                        } else {
                          return Text(
                            "${AppStrings.sold.tr} \n ${snapshot.data}",
                            style: AppTextStyles.headLineStyle4,
                            textAlign: TextAlign.center,
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        AppButton(
          title: AppStrings.done.tr,
          onPressed: () {
            OverlayService.back();
          },
        )
      ],
    );
  }
}