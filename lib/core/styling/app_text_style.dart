
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTextStyles {

  static TextStyle textStyle =
   TextStyle(  fontFamily: 'Almarai',color: AppColors.textColor, fontSize: 16.sp, fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis);

  static TextStyle headLineStyle1 =
   TextStyle(  fontFamily: 'Almarai',fontSize: 23.sp, color: AppColors.textColor, fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis,);

  static TextStyle headLineStyle2 =
   TextStyle(  fontFamily: 'Almarai',fontSize: 21.sp, color: AppColors.textColor, fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis);

  static TextStyle headLineStyle3 =   TextStyle(  fontFamily: 'Almarai',
      fontSize: 17.sp, color: AppColors.textColor, fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis);

  static TextStyle headLineStyle4 =   TextStyle(  fontFamily: 'Almarai',
      fontSize: 14.sp, color: AppColors.textColor , fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis);
}
