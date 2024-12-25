import 'package:ba3_bs_mobile/features/patterns/controllers/pattern_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/validators/app_validator.dart';


class PatternFormHandler with AppValidator {
  PatternController get userManagementController => read<PatternController>();

  final formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passController = TextEditingController();

  RxnString selectedSellerId = RxnString();
  RxnString selectedRoleId = RxnString();

/*  void init(UserModel? user) {
    if (user != null) {
      userManagementController.selectedUserModel = user;

      selectedSellerId.value = user.userSellerId!;
      selectedRoleId.value = user.userRoleId!;

      userNameController.text = user.userName ?? '';
      passController.text = user.userPassword ?? '';
    } else {
      userManagementController.selectedUserModel = null;

      selectedSellerId.value = null;
      selectedRoleId.value = null;

      clear();
    }
  }*/

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


  String? passwordValidator(String? value, String fieldName) => isPasswordValid(value, fieldName);

  String? defaultValidator(String? value, String fieldName) => isFieldValid(value, fieldName);
}
