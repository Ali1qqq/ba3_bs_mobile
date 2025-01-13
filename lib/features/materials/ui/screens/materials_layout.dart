import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
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
                title: const Text("المواد"),
                actions: [],
              ),
              body: Column(
                children: [
                  AppMenuItem(
                      text: "معاينة المواد",
                      onTap: () {
                        read<MaterialController>()
                          ..reloadMaterials()
                          ..navigateToAllMaterialScreen();
                      }),
                  AppMenuItem(
                      text: "اضافة المواد",
                      onTap: () {
                        read<MaterialController>().navigateToAddOrUpdateMaterialScreen();
                      }),
                ],
              ),
            ),
            LoadingDialog(
              isLoading: read<MaterialController>().saveAllMaterialsRequestState.value == RequestState.loading,
              message: '${(progress * 100).toStringAsFixed(2)}% من المواد',
              fontSize: 14.sp,
            )
          ],
        );
      }),
    );
  }
}
