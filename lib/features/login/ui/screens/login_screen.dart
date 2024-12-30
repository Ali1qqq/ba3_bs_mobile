import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../users_management/controllers/user_management_controller.dart';
import '../widgets/login_header_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userManagementController = read<UserManagementController>();
    return Scaffold(
      body: Center(
        child: Container(
          width: 0.8.sw,
          height: 0.8.sh,
          padding: EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.grayColor, blurRadius: 25, spreadRadius: 0.1)],
            color: Colors.white,
          ),
          child: ListView(
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: 0.35.sh, child: const LoginHeaderText()),
              Divider(),
              Container(
                padding: EdgeInsets.all(15),
                height: 0.4.sh,
                child: Column(
                  // spacing: 15,
                  children: [
                    Text(
                      "تسجيل الدخول",
                      style: AppTextStyles.headLineStyle1,
                    ),
                    VerticalSpace(),
                    SizedBox(
                      child: TextFormField(
                        decoration: InputDecoration(
                          label: Text('اسم الحساب'),
                          filled: true,
                          fillColor: AppColors.backGroundColor,
                        ),
                        controller: userManagementController.loginNameController,
                      ),
                    ),
                    VerticalSpace(),
                    SizedBox(
                      child: Obx(
                        () => TextFormField(
                          maxLength: 6,
                          obscureText: !userManagementController.isPasswordVisible.value,
                          onFieldSubmitted: (value) {
                            userManagementController.checkUserStatus();
                          },
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
                    VerticalSpace(20),
                    InkWell(
                      onTap: () {
                        userManagementController.checkUserStatus();
                      },
                      child: Container(
                        height: 32.h,
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
                    Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
