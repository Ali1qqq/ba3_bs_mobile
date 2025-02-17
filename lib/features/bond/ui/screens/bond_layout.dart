import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/widgets/organized_widget.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/dialogs/loading_dialog.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../widgets/bond_layout/bond_item_widget.dart';

class BondLayout extends StatelessWidget {
  const BondLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final progress = read<AllBondsController>().uploadProgress.value;

      return Stack(
        children: [
          GetBuilder<AllBondsController>(builder: (controller) {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(15.0),
                child: OrganizedWidget(
                  bodyWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: BondType.values.toList().map(
                      (bondType) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: BondItemWidget(
                            bondsController: controller,
                            onTap: () {
                              controller.openFloatingBondDetails(context, bondType);
                            },
                            bondType: bondType,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
            );
          }),
          LoadingDialog(
            isLoading: read<AllBondsController>().saveAllBondsRequestState.value == RequestState.loading,
            message: '${(progress * 100).toStringAsFixed(2)}% ${AppStrings.from.tr} ${AppStrings.bonds.tr}',
            fontSize: 14.sp,
          )
        ],
      );
    });
  }
}