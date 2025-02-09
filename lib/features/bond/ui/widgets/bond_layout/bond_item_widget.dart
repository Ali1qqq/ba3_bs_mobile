import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:ba3_bs_mobile/core/widgets/app_button.dart';
import 'package:ba3_bs_mobile/features/bond/ui/widgets/bond_layout/body_bond_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../controllers/bonds/all_bond_controller.dart';

class BondItemWidget extends StatelessWidget {
  const BondItemWidget({super.key, required this.onTap, required this.bondType, required this.bondsController});

  final VoidCallback onTap;
  final BondType bondType;
  final AllBondsController bondsController;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15),
        height: 160.w,
        width: 0.9.sw,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1,
            color: Color(int.parse("0xff${bondType.color}")),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    bondType.value,
                    style: AppTextStyles.headLineStyle2,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                Image.asset(
                  bondType.icon,
                  width: 0.1.sw,
                  height: 0.035.sh,
                  // color: index == tabIndex ? AppColors.whiteColor : AppColors.grayColor,
                ),
              ],
            ),
            Spacer(),

            BodyBondLayoutWidget(firstText: "من  ${bondType.from}", secondText: "الى  ${bondsController.allBondsCounts(bondType)}"),
            // BodyBondLayoutWidget(firstText: "العدد الكلي :", secondText: ((bondType.to-bondType.from)+1).toString()),
            Spacer(),
            AppButton(
              title: "جديد",
              onPressed: onTap,
              iconData: Icons.add,
              color: Color(int.parse("0xff${bondType.color}")).withAlpha(220),
            )
          ],
        ));
  }
}
