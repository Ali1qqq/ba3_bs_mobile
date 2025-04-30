import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextStyle textStyle = TextStyle(
      fontFamily: 'Almarai',
      color: AppColors.textColor,
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      overflow: TextOverflow.ellipsis);

  static TextStyle headLineStyle1 = TextStyle(
    fontFamily: 'Almarai',
    fontSize: 19.sp,
    color: AppColors.textColor,
    fontWeight: FontWeight.bold,
    overflow: TextOverflow.ellipsis,
  );

  static TextStyle headLineStyle2 = TextStyle(
      fontFamily: 'Almarai',
      fontSize: 17.sp,
      color: AppColors.textColor,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis);

  static TextStyle headLineStyle3 = TextStyle(
      fontFamily: 'Almarai',
      fontSize: 13.sp,
      color: AppColors.textColor,
      fontWeight: FontWeight.w500,
      overflow: TextOverflow.ellipsis);

  static TextStyle headLineStyle4 = TextStyle(
      fontFamily: 'Almarai',
      fontSize: 10.sp,
      color: AppColors.textColor,
      fontWeight: FontWeight.w500,
      overflow: TextOverflow.ellipsis);
}
