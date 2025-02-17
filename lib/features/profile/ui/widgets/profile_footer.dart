import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/widgets/language_dropdown.dart';
import '../../../users_management/controllers/user_management_controller.dart';

class ProfileFooter extends StatelessWidget {
  const ProfileFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        LanguageDropdown(),
        GestureDetector(
          onTap: () {
            read<UserManagementController>().logOut();
          },
          child: Container(
            padding: EdgeInsets.all(15.h),
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: AppColors.blueColor),
            child: Text(
              AppStrings.logout.tr,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}