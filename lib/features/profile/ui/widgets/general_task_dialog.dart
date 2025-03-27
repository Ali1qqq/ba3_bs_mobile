import 'dart:io';

import 'package:ba3_bs_mobile/core/constants/app_assets.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/task_status_extension.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:ba3_bs_mobile/features/user_task/data/model/user_task_model.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../../core/widgets/app_button.dart';

class GeneralTaskDialog extends StatelessWidget {
  final UserTaskModel task;

  const GeneralTaskDialog({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserManagementController>(builder: (userManagementController) {
      return Column(
        children: [
          Container(
            height: 370,
            color: Colors.white,
            alignment: Alignment.center,
            child: userManagementController.image == null && (!task.status.isFinished)
                ? Text(AppStrings.uploadImage.tr, style: AppTextStyles.headLineStyle3)
                : GestureDetector(
                onTap: () {
                  if (task.status.isFinished) {
                    AppUIUtils.showFullScreenNetworkImage(context, task.taskImage!);
                  } else {
                    AppUIUtils.showFullScreenFileImage(context, userManagementController.image!.path);
                  }
                },
                child: task.status.isFinished
                    ? FadeInImage.assetNetwork(
                  placeholder: AppAssets.loadingImage,
                  image: task.taskImage!,
                  fit: BoxFit.cover,
                  placeholderScale: 5.0,
                  // تصغير حجم الـ placeholder

                  height: 370,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image, size: 50, color: Colors.grey); // أيقونة عند فشل التحميل
                  },
                )
                    : Image.file(
                  File(
                    userManagementController.image!.path,
                  ),
                  fit: BoxFit.cover,
                  height: 350,
                )),
          ),
          Spacer(),
          if (!task.status.isFinished)
            Row(
              children: [
                AppButton(
                  title: AppStrings.uploadImage.tr,
                  onPressed: userManagementController.pickImage,
                  iconData: FontAwesomeIcons.upload,
                  color: Colors.green,
                ),
                Spacer(),
                AppButton(
                  title: AppStrings.save.tr,
                  iconData: FontAwesomeIcons.add,
                  onPressed: () {
                    userManagementController.updateGeneralTask(task: task);
                  },
                )
              ],
            ),
          if (task.status.isFinished)
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text(
                AppStrings.taskEndIn.tr,
                style: AppTextStyles.headLineStyle3,
              ),
              Spacer(),
              Text(
                AppServiceUtils.formatDateTime(task.endedAt),
                style: AppTextStyles.headLineStyle3.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              Spacer(),
            ])
        ],
      );
    });
  }
}