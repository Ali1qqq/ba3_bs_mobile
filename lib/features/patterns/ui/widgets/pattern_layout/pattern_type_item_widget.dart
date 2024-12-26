
import 'package:flutter/material.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_button.dart';
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
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12), topLeft: Radius.circular(12)),
            border: Border.all(color: AppColors.grayColor, width: 2),
          ),
          child: Column(
            spacing: 5,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 220,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    billTypeModel.shortName!,
                    style: AppTextStyles.headLineStyle3.copyWith(color: Colors.white),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              BodyPatternWidget(
                  firstText: '${BillAccounts.caches.label} :',
                  secondText: billTypeModel.accounts![BillAccounts.caches]?.accName ?? ""),
              BodyPatternWidget(
                  firstText: '${BillAccounts.materials.label} :',
                  secondText: billTypeModel.accounts![BillAccounts.materials]?.accName ?? ""),
              BodyPatternWidget(
                  firstText: '${BillAccounts.additions.label} :',
                  secondText: billTypeModel.accounts![BillAccounts.additions]?.accName ?? ""),
              BodyPatternWidget(
                  firstText: '${BillAccounts.discounts.label} :',
                  secondText: billTypeModel.accounts![BillAccounts.discounts]?.accName ?? ""),
              BodyPatternWidget(
                  firstText: '${BillAccounts.gifts.label} :',
                  secondText: billTypeModel.accounts![BillAccounts.gifts]?.accName ?? ""),
              BodyPatternWidget(
                  firstText: "${BillAccounts.exchangeForGifts.label} :",
                  secondText: billTypeModel.accounts![BillAccounts.exchangeForGifts]?.accName ?? ""),
              BodyPatternWidget(
                  firstText: "${BillAccounts.store.label} :",
                  secondText: billTypeModel.accounts![BillAccounts.store]?.accName ?? ""),
              const Spacer(),
              AppButton(
                title: 'تعديل',
                onPressed: onTap,
                iconData: Icons.mode_edit_outline_rounded,
                color: Colors.green,
              )
            ],
          ),
        ));
  }
}
