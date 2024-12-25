import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../sellers/controllers/sellers_controller.dart';
import '../../../controllers/user_management_controller.dart';

class AddEditUserForm extends StatelessWidget {
  const AddEditUserForm({
    super.key,
    required this.userManagementController,
    required this.sellerController,
  });

  final UserManagementController userManagementController;
  final SellerController sellerController;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 15,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Form(
          key: userManagementController.userFormHandler.formKey,
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
                  controller: userManagementController.userFormHandler.userNameController,
                  validator: (value) => userManagementController.userFormHandler.defaultValidator(value, 'اسم الحساب'),
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
                  controller: userManagementController.userFormHandler.passController,
                  validator: (value) => userManagementController.userFormHandler.passwordValidator(value, 'كلمة السر'),
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
            ),
          );
        }),
      ],
    );
  }
}
