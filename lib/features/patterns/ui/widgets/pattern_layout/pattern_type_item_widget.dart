import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:ba3_bs_mobile/core/widgets/app_button.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:ba3_bs_mobile/features/patterns/ui/widgets/pattern_layout/body_pattern_widget.dart';
import 'package:flutter/material.dart';

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
              VerticalSpace(5),
              BodyPatternWidget(
                  visible: billTypeModel.billPatternType?.hasCashesAccount,
                  firstText: '${BillAccounts.caches.label} :',
                  secondText: billTypeModel.accounts?[BillAccounts.caches]?.accName ?? ""),
              BodyPatternWidget(
                  visible: billTypeModel.billPatternType?.hasMaterialAccount,
                  firstText: '${BillAccounts.materials.label} :',
                  secondText: billTypeModel.accounts?[BillAccounts.materials]?.accName ?? ""),
              BodyPatternWidget(
                  visible: billTypeModel.billPatternType?.hasAdditionsAccount,
                  firstText: '${BillAccounts.additions.label} :',
                  secondText: billTypeModel.accounts?[BillAccounts.additions]?.accName ?? ""),
              BodyPatternWidget(
                  visible: billTypeModel.billPatternType?.hasDiscountsAccount,
                  firstText: '${BillAccounts.discounts.label} :',
                  secondText: billTypeModel.accounts?[BillAccounts.discounts]?.accName ?? ""),
              BodyPatternWidget(
                  visible: billTypeModel.billPatternType?.hasGiftsAccount,
                  firstText: '${BillAccounts.gifts.label} :',
                  secondText: billTypeModel.accounts?[BillAccounts.gifts]?.accName ?? ""),
              BodyPatternWidget(
                  visible: billTypeModel.billPatternType?.hasGiftsAccount,
                  firstText: "${BillAccounts.exchangeForGifts.label} :",
                  secondText: billTypeModel.accounts?[BillAccounts.exchangeForGifts]?.accName ?? ""),
              BodyPatternWidget(
                firstText: "${BillAccounts.store.label} :",
                secondText: billTypeModel.accounts?[BillAccounts.store]?.accName ?? "",
              ),
              VerticalSpace(5),
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
