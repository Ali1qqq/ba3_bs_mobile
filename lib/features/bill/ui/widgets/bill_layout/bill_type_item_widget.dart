import 'dart:math';

import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';

class BillTypeItemWidget extends StatelessWidget {
  const BillTypeItemWidget({
    super.key,
    required this.onTap,
    required this.onPendingBillsPressed,
    required this.text,
    this.color = Colors.white,
    this.isLoading = false,
    required this.pendingBillsCounts,
    required this.allBillsCounts,
  });

  final VoidCallback onTap;
  final String text;
  final Color color;
  final bool isLoading;
  final int pendingBillsCounts;
  final int allBillsCounts;

  final VoidCallback onPendingBillsPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: max(.25.sw, 350),
        height: 130,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
                border: Border.all(color: color, width: 2),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: max(.25.sw, 350),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        spacing: 5,
                        children: [
                          Text(
                            AppStrings.allBills.tr,
                          ),
                          Text(
                            '$allBillsCounts',
                            style: TextStyle(color: color),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: onPendingBillsPressed,
                        child: Row(
                          spacing: 5,
                          children: [
                            Text(
                              AppStrings.pendingBill.tr,
                            ),
                            Text(
                              '$pendingBillsCounts',
                              style: TextStyle(color: color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 220,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5)),
                ),
                alignment: Alignment.center,
                child: Text(
                  text.tr,
                  style: AppTextStyles.headLineStyle3.copyWith(color: Colors.white),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            Positioned(
              bottom: 20 / 2,
              right: 0,
              left: 0,
              child: Center(
                child: AppButton(
                  height: 20,
                  isLoading: isLoading,
                  title: AppStrings.newS.tr,
                  onPressed: onTap,
                  iconData: Icons.add,
                  color: color,
                ),
              ),
            ),
          ],
        ));
  }
}