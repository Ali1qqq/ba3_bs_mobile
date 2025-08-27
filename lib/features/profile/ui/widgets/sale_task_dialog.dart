import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/user_task/data/model/user_task_model.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../floating_window/services/overlay_service.dart';

class SaleTaskDialog extends StatelessWidget {
  final UserTaskModel task;

  const SaleTaskDialog({super.key, required this.task});

  Future<int> _getTotalSales() async {
    int total = 0;
    for (var material in task.materialTask!) {
      final count = await read<UserManagementController>().getCurrentUserMaterialsSales(
        materialId: material.docId!,
        startDay: task.dueDate!,
        endDay: task.createdAt!,
      );
      total += count;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ إجمالي المبيعات
        FutureBuilder<int>(
          future: _getTotalSales(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${AppStrings.sold.tr} (Total): ...",
                  style: AppTextStyles.headLineStyle2,
                ),
              );
            } else if (snapshot.hasError) {
              return Text(
                "${AppStrings.sold.tr} (Total): ❌",
                style: AppTextStyles.headLineStyle2,
              );
            } else {
              return Text(
                "${AppStrings.sold.tr} (Total): ${snapshot.data}",
                style: AppTextStyles.headLineStyle2,
              );
            }
          },
        ),
        Spacer(),
        Container(
          height: 360,
          color: Colors.white,
          alignment: Alignment.center,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) => Divider(),
            itemCount: task.materialTask!.length,
            itemBuilder: (context, materialIndex) {
              return GestureDetector(
                onTap: () async {
                  String? imgUrl = await read<MaterialController>().getMaterialImageById(matId: task.materialTask![materialIndex].docId!);
                  if (imgUrl != null) {
                    if (!context.mounted) return;
                    AppUIUtils.showFullScreenNetworkImage(context, imgUrl);
                  } else {
                    AppUIUtils.onFailure("صورة المنتج غير موجودة");
                  }
                  log(task.materialTask![materialIndex].docId!);
                },
                child: ListTile(
                  title: Text(
                    task.materialTask![materialIndex].materialName!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${AppStrings.identificationNumber.tr}: ${task.materialTask![materialIndex].docId}",
                    style: TextStyle(color: Colors.grey),
                  ),
                  leading: Icon(Icons.inventory),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder<int>(
                        future: read<UserManagementController>().getCurrentUserMaterialsSales(
                          materialId: task.materialTask![materialIndex].docId!,
                          startDay: task.dueDate!,
                          endDay: task.createdAt!,
                        ),
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
                ),
              );
            },
          ),
        ),
        Spacer(),
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