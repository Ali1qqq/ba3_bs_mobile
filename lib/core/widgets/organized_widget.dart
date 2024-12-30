import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrganizedWidget extends StatelessWidget {
  const OrganizedWidget({
    super.key,
    this.titleWidget,
    required this.bodyWidget,
  });

  final Widget? titleWidget;
  final Widget bodyWidget;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (titleWidget != null)
            Column(
              children: [
                Container(
                  height: 35,
                  decoration: BoxDecoration(
                    // boxShadow: [BoxShadow(color: AppColors.blueColor, blurRadius: 10, spreadRadius: 0.2)],
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [Expanded(child: titleWidget!)],
                  ),
                ),
                Container(
                  width: 1.sw,
                  height: 1,
                  color: Colors.white10,
                ),
              ],
            ),
          Container(
            padding: EdgeInsets.all(16.0),
            width: 1.sw,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // boxShadow: [BoxShadow(color: AppColors.grayColor, blurRadius: 5, spreadRadius: 0.2)],
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                15,
              ),
            ),
            child: bodyWidget,
          ),
        ],
      ),
    );
  }
}
