import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/widgets/organized_widget.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../widgets/bond_layout/bond_item_widget.dart';

class BondLayout extends StatelessWidget {
  const BondLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllBondsController>(builder: (controller) {
      return Container(
        padding: EdgeInsets.all(8),
        width: 1.sw,
        child: OrganizedWidget(
          // titleWidget: Align(
          //   child: Text(
          //     "السندات",
          //     style: AppTextStyles.headLineStyle2.copyWith(color: AppColors.blueColor),
          //   ),
          // ),
          bodyWidget: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              runSpacing: 10,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: BondType.values.toList().map(
                (bondType) {
                  return BondItemWidget(
                    onTap: () {
                      controller.openFloatingBondDetails(context, bondType);
                    },
                    bondType: bondType,
                  );
                },
              ).toList(),
            ),
          ),
        ),
      );
    });
  }
}
