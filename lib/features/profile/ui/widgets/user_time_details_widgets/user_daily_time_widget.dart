import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/organized_widget.dart';

class UserDailyTimeWidget extends StatelessWidget {
  const UserDailyTimeWidget({
    super.key,
    required this.userModel,
  });

  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return OrganizedWidget(
        titleWidget: Center(
            child: Text(
          AppStrings.workingHours.tr,
          style: AppTextStyles.headLineStyle2,
        )),
        bodyWidget: Column(
          children: [
            ListView.separated(
              separatorBuilder: (context, index) => VerticalSpace(),
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: userModel.userWorkingHours?.length ?? 0,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: 30.w,
                      child: Text(
                        userModel.userWorkingHours?[index.toString()]?.enterTime ?? '',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headLineStyle4,
                      )),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.grayColor,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.grayColor,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                      width: 30.w,
                      child: Text(
                        userModel.userWorkingHours![index.toString()]?.outTime ?? '',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headLineStyle4,
                      )),
                ],
              ),
            ),
          ],
        ));
  }
}