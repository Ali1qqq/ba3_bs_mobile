import 'dart:io';

import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../users_management/controllers/user_management_controller.dart';

class MainHeader extends StatelessWidget {
  const MainHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing:(Platform.isWindows || Platform.isMacOS)? 10:4,
      children: [
        SizedBox(
          height:(Platform.isWindows || Platform.isMacOS)?  0.025.sh:0.035.sh,
          width: 0.15.sw,
          child: Row(
            children: [
              Text(
                'المستخدم: ',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Text(
                  read<UserManagementController>().loggedInUserModel?.userName ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            read<UserManagementController>().userStatus = UserManagementStatus.first;
            Get.offAllNamed(AppRoutes.loginScreen);
          },
          child: Container(
            height: (Platform.isWindows || Platform.isMacOS)? 0.05.sh:0.06.sh,
            width: 0.15.sw,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: AppColors.blueColor),
            child: const Text(
              'تسجيل الخروج',
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
