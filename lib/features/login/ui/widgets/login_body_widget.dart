import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../users_management/controllers/user_management_controller.dart';

class LoginBodyWidget extends StatelessWidget {
  const LoginBodyWidget({
    super.key,
    required this.userManagementController,
  });

  final UserManagementController userManagementController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      // width: 1.sw,
      height: 0.4.sh,
      child: Column(
        spacing: 15,
        children: [
          const Spacer(),
          Text(
            AppStrings.login.tr,
            style: AppTextStyles.headLineStyle1,
          ),
          SizedBox(
            width: .8.sw,
            child: TextFormField(
              decoration: InputDecoration(
                label: Text(AppStrings.accountName.tr),
                filled: true,
                fillColor: AppColors.backGroundColor,
              ),
              controller: userManagementController.loginNameController,
            ),
          ),
          SizedBox(
            width: .8.sw,
            child: Obx(
              () => TextFormField(
                maxLength: 6,
                obscureText: !userManagementController.isPasswordVisible.value,
                decoration: InputDecoration(
                  label: Text(AppStrings.password.tr),
                  suffixIcon: IconButton(
                    icon: Icon(
                      userManagementController.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                      color: AppColors.blueColor,
                    ),
                    onPressed: () {
                      userManagementController.updatePasswordVisibility();
                    },
                  ),
                  errorMaxLines: 2,
                  filled: true,
                  fillColor: AppColors.backGroundColor,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(6),
                ],
                controller: userManagementController.loginPasswordController,
              ),
            ),
          ),
          LoginButtonWidget(
            text: AppStrings.enter.tr,
            onTap: () {
              userManagementController.validateUserInputs();
            },
          ),
          Obx(() => userManagementController.isGuestLoginButtonVisible.value
              ? LoginButtonWidget(
                  text: AppStrings.registrationAsAGust.tr,
                  onTap: () {
                    userManagementController.loginAsGuest();
                  },
                )
              : SizedBox.shrink()),
          const Spacer(),
        ],
      ),
    );
  }
}

class LoginButtonWidget extends StatelessWidget {
  const LoginButtonWidget({
    super.key,
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 32.h,
        width: .8.sw,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: AppColors.blueColor,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}