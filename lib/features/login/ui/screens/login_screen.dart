import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../users_management/controllers/user_management_controller.dart';
import '../widgets/login_header_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userManagementController = read<UserManagementController>();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoginHeaderText(),
          VerticalSpace(),
          Center(
            child: Column(
              spacing: 15,
              children: [
                SizedBox(
                  width:  .6.sw,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      label: Text('اسم الحساب'),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    controller: userManagementController.loginNameController,
                  ),
                ),
                SizedBox(
                  width:  .6.sw,
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
                        fillColor: Colors.white,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                      ],
                      controller: userManagementController.loginPasswordController,
                    ),
                  ),
                )
              ],
            ),
          ),
          VerticalSpace(20),
          InkWell(
            onTap: () {
              userManagementController.checkUserStatus();
            },
            child: Container(
              height: 32.h,
              width: .6.sw,
              alignment: Alignment.center,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: AppColors.blueColor),
              child: Text(
                'دخول',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
