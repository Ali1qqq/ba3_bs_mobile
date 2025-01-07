import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/validators/app_validator.dart';
import '../controllers/user_management_controller.dart';
import '../data/models/user_model.dart';

class UserFormHandler with AppValidator {
  UserManagementController get userManagementController => read<UserManagementController>();

  final formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passController = TextEditingController();

  RxnString selectedSellerId = RxnString();
  RxnString selectedRoleId = RxnString();

  void init(UserModel? user) {
    if (user != null) {
      userManagementController.selectedUserModel = user;

      selectedSellerId.value = user.userSellerId!;
      selectedRoleId.value = user.userRoleId!;

      userNameController.text = user.userName ?? '';
      passController.text = user.userPassword ?? '';
      userManagementController.workingHours=user.userWorkingHours??{};
      userManagementController.holidays=user.userHolidays?.toSet()?? {};
    } else {
      userManagementController.selectedUserModel = null;

      selectedSellerId.value = null;
      selectedRoleId.value = null;
      userManagementController.workingHours={};
      userManagementController.holidays= {};

      clear();
    }
  }

  void clear() {
    userNameController.clear();
    passController.clear();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  void dispose() {
    userNameController.dispose();
    passController.dispose();
  }

  set setSellerId(String? sellerId) {
    selectedSellerId.value = sellerId;
  }

  set setRoleId(String? roleId) {
    selectedRoleId.value = roleId;
  }

  void updatePasswordVisibility() {
    userManagementController.isPasswordVisible.value = !userManagementController.isPasswordVisible.value;
  }

  String? passwordValidator(String? value, String fieldName) => isPasswordValid(value, fieldName);

  String? defaultValidator(String? value, String fieldName) => isFieldValid(value, fieldName);
}
