import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ChequesTypeItemWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ChequesTypeItemWidget({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
          width: 1.sw,
           decoration: BoxDecoration(
             color: AppColors.grayColor,
             borderRadius: BorderRadius.circular(8)
           ),
          height: 100.h,
          alignment: Alignment.center,


          child: Text(
            text,
            style: AppTextStyles.headLineStyle1.copyWith(color: Colors.white,),
            textDirection: TextDirection.rtl,
          )),
    );
  }
}
