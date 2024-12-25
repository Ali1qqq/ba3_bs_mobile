import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.unSelectedIcon,
    required this.index,
    required this.tabIndex,
    required this.onTap,
  });

  final String title;
  final String icon;
  final String unSelectedIcon;
  final int index;
  final int tabIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Durations.medium2,
        width: 0.15.sw,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: index == tabIndex ? AppColors.blueColor : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.centerRight,
        child: Row(
          spacing: 8,
          children: [
            Image.asset(
              index == tabIndex ? icon : unSelectedIcon,
              width: 0.035.sw,
              height: 0.035.sh,
              // color: index == tabIndex ? AppColors.whiteColor : AppColors.grayColor,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: index == tabIndex ? AppColors.whiteColor : AppColors.grayColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
