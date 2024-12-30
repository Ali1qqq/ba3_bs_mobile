import 'dart:developer';

import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:ba3_bs_mobile/core/widgets/organized_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../../sellers/controllers/sellers_controller.dart';
import '../../../controllers/user_management_controller.dart';

class UserDetailsForm extends StatelessWidget {
  const UserDetailsForm({
    super.key,
    required this.userManagementController,
    required this.sellerController,
  });

  final UserManagementController userManagementController;
  final SellerController sellerController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
        titleWidget: Center(
            child: Text(
          "معلومات المستخدم",
          style: AppTextStyles.headLineStyle2,
        )),
        bodyWidget: Form(
          key: userManagementController.userFormHandler.formKey,
          child: Column(
            spacing: 10,
            children: [
              TextAndExpandedChildField(
                label: 'اسم الحساب',
                width: 1.sw,
                child: CustomTextFieldWithoutIcon(
                  filedColor: AppColors.backGroundColor,
                  validator: (value) => userManagementController.userFormHandler.defaultValidator(value, 'اسم الحساب'),
                  textEditingController: userManagementController.userFormHandler.userNameController,
                  suffixIcon: const SizedBox.shrink(),
                ),
              ),
              TextAndExpandedChildField(
                label: 'كلمة السر',
                width: 1.sw,
                child: CustomTextFieldWithoutIcon(
                  filedColor: AppColors.backGroundColor,
                  validator: (value) => userManagementController.userFormHandler.passwordValidator(value, 'كلمة السر'),
                  textEditingController: userManagementController.userFormHandler.passController,
                  // suffixIcon: const SizedBox.shrink(),
                  maxLength: 6,
                  height: 60,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
              ),
              TextAndExpandedChildField(
                label: 'الصلاحيات',
                width: 1.sw,
                child: Obx(() {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.backGroundColor,
                    ),
                    child: DropdownButton<String>(
                      hint: const Text('الصلاحيات'),
                      icon: const SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      value: userManagementController.userFormHandler.selectedRoleId.value,
                      items: userManagementController.allRoles
                          .map(
                            (role) => DropdownMenuItem(
                              value: role.roleId,
                              child: Text(role.roleName!),
                            ),
                          )
                          .toList(),
                      onChanged: (role) {
                        log('selectedRoleId $role');
                        userManagementController.userFormHandler.setRoleId = role;
                      },
                    ),
                  );
                }),
              ),
              TextAndExpandedChildField(
                label: 'البائع',
                width: 1.sw,
                child: Obx(() {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.backGroundColor,
                    ),
                    child: DropdownButton<String>(
                      hint: const Text('البائع'),
                      icon: const SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      value: userManagementController.userFormHandler.selectedSellerId.value,
                      items: sellerController.sellers
                          .map(
                            (seller) => DropdownMenuItem(
                              value: seller.costGuid,
                              child: Text(seller.costName ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (sellerId) {
                        log('selectedSellerId $sellerId');
                        userManagementController.userFormHandler.setSellerId = sellerId;
                      },
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
