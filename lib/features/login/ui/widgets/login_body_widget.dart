import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../../core/widgets/app_spacer.dart';
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
      width: 0.35.sw,
      child: Column(
        spacing: 15,
        children: [
          const Spacer(),
          Text(
            "تسجيل الدخول",
            style: AppTextStyles.headLineStyle1,
          ),
          SizedBox(
            width: .25.sw,
            child: TextFormField(
              decoration: InputDecoration(
                label: const Text('اسم الحساب'),
                filled: true,
                fillColor: AppColors.backGroundColor,
              ),
              controller: userManagementController.loginNameController,
            ),
          ),
          SizedBox(
            width: .25.sw,
            child: Obx(
              () => TextFormField(
                maxLength: 6,
                obscureText: !userManagementController.isPasswordVisible.value,
                decoration: InputDecoration(
                  label: const Text('كلمة السر'),
                  suffixIcon: IconButton(
                    icon: Icon(
                      userManagementController.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                      color: AppColors.blueColor,
                    ),
                    onPressed: () {
                      userManagementController.userFormHandler.updatePasswordVisibility();
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
          const VerticalSpace(20),
          LoginButtonWidget(
            text: 'دخول',
            onTap: () {
              userManagementController.validateUserInputs();
            },
          ),
          Obx(() => userManagementController.isGuestLoginButtonVisible.value
              ? LoginButtonWidget(
                  text: 'ضيف',
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
        width: .25.sw,
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
