import 'dart:developer';

import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/validators/app_validator.dart';
import '../../../core/utils/app_service_utils.dart';
import '../data/models/user_model.dart';

class UserFormHandler with AppValidator {
  UserDetailsController get userDetailsController => read<UserDetailsController>();

  final formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passController = TextEditingController();

  RxnString selectedSellerId = RxnString();
  RxnString selectedRoleId = RxnString();

  Rx<bool> get isUserActive => userActiveStatus.value == UserActiveStatus.active ? true.obs : false.obs;
  Rx<UserActiveStatus> userActiveStatus = UserActiveStatus.active.obs;

  void init(UserModel? user) {
    if (user != null) {
      userDetailsController.selectedUserModel = user;

      selectedSellerId.value = user.userSellerId!;
      selectedRoleId.value = user.userRoleId!;

      userNameController.text = user.userName ?? '';
      passController.text = user.userPassword ?? '';
      userActiveStatus.value = user.userActiveStatus!;

      userDetailsController.workingHours = user.userWorkingHours ?? {};
      userDetailsController.holidays = user.userHolidays?.toSet() ?? {};
      log(isUserActive.toString());
    } else {
      userDetailsController.selectedUserModel = null;

      selectedSellerId.value = null;
      selectedRoleId.value = null;
      userActiveStatus.value = UserActiveStatus.active;
      userDetailsController.workingHours = {};
      userDetailsController.holidays = {};

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
    userDetailsController.update();
  }

  String? passwordValidator(String? value, String fieldName) => isPasswordValid(value, fieldName);

  String? defaultValidator(String? value, String fieldName) => isFieldValid(value, fieldName);

  String userListSelectedMonth = AppConstants.months.keys.first;

  List<String> get userHolidays => userDetailsController.selectedUserModel?.userHolidays?.toList() ?? [];

  List<String>? get userHolidaysWithDay => userHolidays
      .map(
        (date) => AppServiceUtils.getDayNameAndMonthName(date),
      )
      .toList();

  List<String>? get userHolidaysWithDayAtMoth => userHolidays
      .where(
        (element) => element.split('-')[1].split("-")[0] == AppConstants.months[userListSelectedMonth],
      )
      .map(
        (date) => AppServiceUtils.getDayNameAndMonthName(date),
      )
      .toList();

  List<String> get userHolidaysAtMoth => userHolidays
      .where(
        (element) => element.split('-')[1].split("-")[0] == AppConstants.months[userListSelectedMonth],
      )
      .toList();

  int get userHolidaysLength => userHolidays.length;

  int get userHolidaysLengthAtMonth => userHolidaysAtMoth.length;

  List<UserTimeModel>? get userTimeModelWithTotalDelayAndEarlier {
    return userDetailsController.selectedUserModel?.userTimeModel?.values
        .map(
          (e) => e.copyWith(dayName: e.dayName?.split('-')[1].split('-')[0].toString()),
        )
        .toList()
        .mergeBy(
          (p0) => p0.dayName,
          (accumulated, current) => current.copyWithAddTime(
            totalLogInDelay: accumulated.totalLogInDelay,
            totalOutEarlier: accumulated.totalOutEarlier,
          ),
        );
  }

  UserTimeModel? get userTimeModelWithTotalDelayAndEarlierAtMonth => userTimeModelWithTotalDelayAndEarlier?.firstWhereOrNull(
        (element) => element.dayName == AppConstants.months[userListSelectedMonth],
      );

  int get userTimeModelWithTotalDelayAndEarlierLength => userTimeModelWithTotalDelayAndEarlier?.length ?? 0;

  void updateSelectedMonth(String value) {
    userListSelectedMonth = value.tr;
    userDetailsController.update();
  }

  Map<String, UserTimeModel> get userTimeModelAtMonth =>
      Map.fromEntries(userDetailsController.selectedUserModel?.userTimeModel?.entries.where(
            (userWorkingHour) => userWorkingHour.key.split('-')[1].split('-')[0] == AppConstants.months[userListSelectedMonth],
          ) ??
          []);

  int get userTimeAtMonthLength => userTimeModelAtMonth.length;
}