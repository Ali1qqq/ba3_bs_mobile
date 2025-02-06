import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_details_controller.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../sellers/controllers/sellers_controller.dart';

class AddEditUserForm extends StatelessWidget {
  const AddEditUserForm({
    super.key,
    required this.userDetailsController,
    required this.sellerController,
  });

  final UserDetailsController userDetailsController;
  final SellersController sellerController;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 15,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Form(
          key: userDetailsController.userFormHandler.formKey,
          child: Column(
            spacing: 15,
            children: [
              SizedBox(
                width: .3.sw,
                child: TextFormField(
                  decoration: const InputDecoration(
                    label: Text('اسم الحساب'),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  controller: userDetailsController.userFormHandler.userNameController,
                  validator: (value) => userDetailsController.userFormHandler.defaultValidator(value, 'اسم الحساب'),
                ),
              ),
              SizedBox(
                width: .3.sw,
                child: TextFormField(
                  maxLength: 6,
                  decoration: const InputDecoration(
                    label: Text('كلمة السر'),
                    errorMaxLines: 2,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                  ],
                  controller: userDetailsController.userFormHandler.passController,
                  validator: (value) => userDetailsController.userFormHandler.passwordValidator(value, 'كلمة السر'),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          return SizedBox(
            width: .3.sw,
            child: Container(
              color: Colors.white,
              child: DropdownButton<String>(
                hint: const Text('الصلاحيات'),
                icon: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                value: userDetailsController.userFormHandler.selectedRoleId.value,
                items: read<UserManagementController>().allRoles
                    .map(
                      (role) => DropdownMenuItem(
                        value: role.roleId,
                        child: Text(role.roleName!),
                      ),
                    )
                    .toList(),
                onChanged: (role) {
                  log('selectedRoleId $role');
                  userDetailsController.userFormHandler.setRoleId = role;
                },
              ),
            ),
          );
        }),
        Obx(() {
          return SizedBox(
            width: .3.sw,
            child: Container(
              color: Colors.white,
              child: DropdownButton<String>(
                hint: const Text('البائع'),
                icon: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                value: userDetailsController.userFormHandler.selectedSellerId.value,
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
                  userDetailsController.userFormHandler.setSellerId = sellerId;
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}
