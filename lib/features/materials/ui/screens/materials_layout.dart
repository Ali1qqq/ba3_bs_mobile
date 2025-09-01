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
              // backgroundColor: const Color(0xFFF4F6FA),
              backgroundColor: const Color(0xFFEDF3F8),
              appBar: AppBar(
                title: Text(AppStrings.materials.tr),
                actions: RoleItemType.administrator.hasAdminPermission
                    ? [
                        _buildAdminButton(AppStrings.downloadMaterials.tr, () {
                          read<MaterialController>().fetchAllMaterialFromLocal();
                        }),
                        _buildAdminButton(AppStrings.deletedMaterials.tr, () {
                          read<MaterialController>().deleteAllMaterialFromLocal();
                        }),
                        // _buildAdminButton(AppStrings.downloadGroups.tr, () {
                        //   read<MaterialGroupController>().fetchAllMaterialGroupFromLocal();
                        // }, width: 120),
                      ]
                    : [],
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                child: Column(
                  children: [
                    buildAppMenuItem(
                      icon: Icons.list_alt,
                      title: AppStrings.viewMaterial.tr,
                      onTap: () {
                        read<MaterialController>()
                          ..reloadMaterials()
                          ..navigateToAllMaterialScreen(context: context);
                      },
                    ),
                    buildAppMenuItem(
                      icon: Icons.category,
                      title: AppStrings.viewMaterialGroups.tr,
                      onTap: () {
                        read<MaterialGroupController>().navigateToAllMaterialScreen(context: context);
                      },
                    ),
                    if (RoleItemType.viewProduct.hasAdminPermission)
                      buildAppMenuItem(
                        icon: Icons.add,
                        title: AppStrings.addMaterials.tr,
                        onTap: () {
                          read<MaterialController>().navigateToAddOrUpdateMaterialScreen(context: context);
                        },
                      ),
                    buildAppMenuItem(
                      icon: Icons.search,
                      title: AppStrings.searchMaterial.tr,
                      onTap: () {
                        read<MaterialController>().navigateToSearchMaterialScreen();
                      },
                    ),
                  ],
                ),
              ),
              floatingActionButton: RoleItemType.administrator.hasAdminPermission
                  ? FloatingActionButton(
                      onPressed: () {
                        // read<MaterialsStatementController>().setupAllMaterials();
                        read<MaterialController>().resetMaterialQuantityAndPrice();
                      },
                      backgroundColor: Colors.blue.shade700,
                      child: const Icon(
                        Icons.lock_reset,
                        color: Colors.white,
                      ),
                    )
                  : null,
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

  Widget _buildAdminButton(String title, VoidCallback onPressed, {double? width}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: AppButton(
        title: title,
        width: width ?? 140,
        onPressed: onPressed,
      ),
    );
  }
}