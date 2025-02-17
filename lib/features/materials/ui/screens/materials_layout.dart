import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/core/widgets/app_button.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_group_controller.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/role_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/dialogs/loading_dialog.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_menu_item.dart';

class MaterialLayout extends StatelessWidget {
  const MaterialLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        final progress = read<MaterialController>().uploadProgress.value;

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(AppStrings.materials.tr),
                actions: RoleItemType.administrator.hasAdminPermission
                    ? [
                        Padding(
                          padding: EdgeInsets.all(6),
                          child: AppButton(
                              title: AppStrings.downloadMaterials.tr,
                              onPressed: () {
                                read<MaterialController>().fetchAllMaterialFromLocal();
                              }),
                        ),
                        Padding(
                          padding: EdgeInsets.all(6),
                          child: AppButton(
                              title: AppStrings.deletedMaterials.tr,
                              onPressed: () {
                                read<MaterialController>().deleteAllMaterialFromLocal();
                              }),
                        ),
                        Padding(
                          padding: EdgeInsets.all(6),
                          child: AppButton(
                              width: 100,
                              title: AppStrings.downloadGroups.tr,
                              onPressed: () {
                                read<MaterialGroupController>().fetchAllMaterialGroupGroupFromLocal();
                              }),
                        ),
                      ]
                    : [],
              ),
              body: Column(
                children: [
                  AppMenuItem(
                      text: AppStrings.viewMaterial.tr,
                      onTap: () {
                        read<MaterialController>()
                          ..reloadMaterials()
                          ..navigateToAllMaterialScreen();
                      }),
                  AppMenuItem(
                      text: AppStrings.viewMaterialGroups.tr,
                      onTap: () {
                        read<MaterialGroupController>().navigateToAllMaterialScreen();
                      }),
                  if (RoleItemType.viewProduct.hasAdminPermission)
                    AppMenuItem(
                        text: AppStrings.addMaterials.tr,
                        onTap: () {
                          read<MaterialController>().navigateToAddOrUpdateMaterialScreen(context: context);
                        }),
                ],
              ),
              floatingActionButton: (RoleItemType.administrator.hasAdminPermission)
                  ? FloatingActionButton(onPressed: read<MaterialController>().resetMaterialQuantityAndPrice, child: Icon(Icons.lock_reset))
                  : SizedBox(),
            ),
            LoadingDialog(
              isLoading: read<MaterialController>().saveAllMaterialsRequestState.value == RequestState.loading,
              message: '${(progress * 100).toStringAsFixed(2)}% ${AppStrings.from.tr} ${AppStrings.materials.tr}',
              fontSize: 14.sp,
            )
          ],
        );
      }),
    );
  }
}