import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/styling/app_text_style.dart';

class ProfileInfoRowWidget extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double width;

  const ProfileInfoRowWidget({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.width = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          SizedBox(
            height: 35.h,
            width: 0.4.sw,
            child: Text(
              '$label :',
              style: labelStyle ?? AppTextStyles.headLineStyle2,
              textAlign: TextAlign.start,
            ),
          ),
          SizedBox(
            height: 25,
            child: Text(
              value,
              style: valueStyle ?? AppTextStyles.headLineStyle2,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

// Shimmer box method for individual elements