import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';

class DashBoardAccountShimmerWidget extends StatelessWidget {
  const DashBoardAccountShimmerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 35.w,
        height: 35.h,
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.green.withAlpha(150), border: Border.all(color: AppColors.whiteColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 3,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Text(
                'name',
                style: AppTextStyles.headLineStyle4,
              ),
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Text(
                'balance',
                style: AppTextStyles.headLineStyle4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}