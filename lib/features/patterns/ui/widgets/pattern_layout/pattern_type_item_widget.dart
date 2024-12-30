import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../data/models/bill_type_model.dart';
import 'body_pattern_widget.dart';

class PatternTypeItemWidget extends StatelessWidget {
  const PatternTypeItemWidget({super.key, required this.onTap, required this.billTypeModel, this.color = Colors.white});

  final VoidCallback onTap;
  final BillTypeModel billTypeModel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 500,
        child: Container(
          height: 300.h,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12), topLeft: Radius.circular(12)),
            border: Border.all(color: AppColors.grayColor, width: 2),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 220,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(5), bottomLeft: Radius.circular(5)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    billTypeModel.shortName!,
                    style: AppTextStyles.headLineStyle3.copyWith(color: Colors.white),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              const Spacer(),
              BodyPatternWidget(
                  firstText: '${BillAccounts.caches.label} :', secondText: billTypeModel.accounts![BillAccounts.caches]?.accName ?? ""),
              VerticalSpace(5),
              BodyPatternWidget(
                  firstText: '${BillAccounts.materials.label} :',
                  secondText: billTypeModel.accounts![BillAccounts.materials]?.accName ?? ""),
              VerticalSpace(5),
              BodyPatternWidget(
                  firstText: '${BillAccounts.additions.label} :',
                  secondText: billTypeModel.accounts![BillAccounts.additions]?.accName ?? ""),
              VerticalSpace(5),
              BodyPatternWidget(
                  firstText: '${BillAccounts.discounts.label} :',
                  secondText: billTypeModel.accounts![BillAccounts.discounts]?.accName ?? ""),
              VerticalSpace(5),
              BodyPatternWidget(
                  firstText: '${BillAccounts.gifts.label} :', secondText: billTypeModel.accounts![BillAccounts.gifts]?.accName ?? ""),
              VerticalSpace(5),
              BodyPatternWidget(
                  firstText: "${BillAccounts.exchangeForGifts.label} :",
                  secondText: billTypeModel.accounts![BillAccounts.exchangeForGifts]?.accName ?? ""),
              VerticalSpace(5),
              BodyPatternWidget(
                  firstText: "${BillAccounts.store.label} :", secondText: billTypeModel.accounts![BillAccounts.store]?.accName ?? ""),
              const Spacer(),
              AppButton(
                title: 'تعديل',
                onPressed: onTap,
                iconData: Icons.mode_edit_outline_rounded,
                color: Colors.green,
              ),
              VerticalSpace(),
            ],
          ),
        ));
  }
}
