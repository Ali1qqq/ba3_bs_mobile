import 'dart:developer';

import 'package:ba3_bs_mobile/features/users_management/controllers/user_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/validators/app_validator.dart';
import '../../../core/utils/app_service_utils.dart';
import '../data/models/user_model.dart';

class UserFormHandler with AppValidator {
  UserDetailsController get userManagementController => read<UserDetailsController>();

  final formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passController = TextEditingController();

  RxnString selectedSellerId = RxnString();
  RxnString selectedRoleId = RxnString();

  Rx<bool> get isUserActive => userActiveStatus.value == UserActiveStatus.active ? true.obs : false.obs;
  Rx<UserActiveStatus> userActiveStatus = UserActiveStatus.active.obs;

  void init(UserModel? user) {
    if (user != null) {
      userManagementController.selectedUserModel = user;

      selectedSellerId.value = user.userSellerId!;
      selectedRoleId.value = user.userRoleId!;

      userNameController.text = user.userName ?? '';
      passController.text = user.userPassword ?? '';
      userActiveStatus.value = user.userActiveStatus!;

      userManagementController.workingHours = user.userWorkingHours ?? {};
      userManagementController.holidays = user.userHolidays?.toSet() ?? {};
      log(isUserActive.toString());
    } else {
      userManagementController.selectedUserModel = null;

      selectedSellerId.value = null;
      selectedRoleId.value = null;
      userActiveStatus.value = UserActiveStatus.active;
      userManagementController.workingHours = {};
      userManagementController.holidays = {};

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

  changeUserState() {
    if (isUserActive.value) {
      userActiveStatus.value = UserActiveStatus.inactive;
    } else {
      userActiveStatus.value = UserActiveStatus.active;
    }
    userManagementController.update();
  }

  String? passwordValidator(String? value, String fieldName) => isPasswordValid(value, fieldName);

  String? defaultValidator(String? value, String fieldName) => isFieldValid(value, fieldName);

  List<String> get userHolidays => userManagementController.selectedUserModel?.userHolidays?.toList() ?? [];

  List<String>? get userHolidaysWithDay => userHolidays
      .map(
        (date) => AppServiceUtils.getDayNameAndMonthName(date),
      )
      .toList();

  int get userHolidaysLength => userHolidays.length;
}
