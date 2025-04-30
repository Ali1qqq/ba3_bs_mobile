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
      width: 100.w,
      height: 35.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: AppColors.backGroundColor, border: Border.all(color: AppColors.blueColor)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.headLineStyle4,
            ),
          ),
          Center(
            child: Text(
              balance,
              style: AppTextStyles.headLineStyle4.copyWith(),
            ),
          ),
        ],
      ),
    );
  }
}