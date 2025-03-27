import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../controller/all_task_controller.dart';

class AddTaskMaterialSelected extends StatelessWidget {
  const AddTaskMaterialSelected({
    super.key,
    required this.controller
  });

  final AllTaskController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.center,
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: controller.taskFormHandler.materialTaskList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              controller.taskFormHandler.materialTaskList[index].materialName!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
                "${AppStrings.identificationNumber.tr}: ${controller.taskFormHandler.materialTaskList[index].docId}",
                style: TextStyle(color: Colors.grey)),
            leading: InkWell(
                onTap: () {
                  controller.removeMaterialFromList(index);
                },
                child: Icon(Icons.inventory)),
            trailing: Text(
              " ${AppStrings.quantity.tr} \n ${controller.taskFormHandler.materialTaskList[index].quantity}",
              style: AppTextStyles.headLineStyle4,
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}