import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';

class DashBoardAccountWidget extends StatelessWidget {
  const DashBoardAccountWidget({super.key, required this.name, required this.balance});

  final String name;
  final String balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35.w,
      height: 28.h,
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      alignment: Alignment.center,
      decoration:
      BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white, border: Border.all(color: AppColors.blueColor)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 3,
        children: [
          Expanded(
              child: Text(
                name,
                style: AppTextStyles.headLineStyle4,
              )),
          Text(
            balance,
            style: AppTextStyles.headLineStyle4,
          ),
        ],
      ),
    );
  }
}