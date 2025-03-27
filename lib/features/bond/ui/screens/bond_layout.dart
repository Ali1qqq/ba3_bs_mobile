import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/widgets/organized_widget.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:ba3_bs_mobile/features/bond/ui/widgets/bond_layout/bond_layout_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../core/dialogs/loading_dialog.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_style.dart';
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
              appBar: bondLayoutAppBar(controller),
              body: Container(
                padding: EdgeInsets.all(8),
                width: 1.sw,
                child: OrganizedWidget(
                  titleWidget: Row(
                    children: [
                      Align(
                        child: Text(
                          AppStrings.bonds.tr,
                          style: AppTextStyles.headLineStyle2.copyWith(color: AppColors.blueColor),
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        tooltip: AppStrings.refresh.tr,
                        icon: Icon(
                          FontAwesomeIcons.refresh,
                          color: AppColors.lightBlueColor,
                        ),
                        onPressed: controller.refreshBondsTypes,
                      ),
                    ],
                  ),
                  bodyWidget: Column(
                    // padding: const EdgeInsets.all(15.0),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                    ],
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