import 'dart:developer';

import 'package:ba3_bs_mobile/core/interfaces/i_account_type_selection_handler.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/validators/app_validator.dart';

class AccountFromHandler with AppValidator implements IAccountTypeSelectionHandler {
  AccountsController get accountController => read<AccountsController>();

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController latinNameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController accParentName = TextEditingController();
  AccountType accountType = AccountType.normal;

  AccountModel? accountParentModel;

  void init({AccountModel? accountModel}) {
    if (accountModel != null) {
      nameController.text = accountModel.accName!;
      latinNameController.text = accountModel.accLatinName!;
      codeController.text = accountModel.accCode!;
      accountParentModel = accountController.getAccountModelById(accountModel.id!)!;
      accParentName.text = accountParentModel!.accName!;
      accountType = AccountType.byIndex(accountModel.accType!);
    } else {
      log("accountModel =null");
      accountParentModel = null;

      clear();
    }
  }

  void clear() {
    nameController.clear();
    codeController.clear();
    accParentName.clear();
    latinNameController.clear();
    accountParentModel = null;
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  void dispose() {
    nameController.dispose();
    codeController.dispose();
    accParentName.dispose();
    latinNameController.dispose();
  }

  String? defaultValidator(String? value, String fieldName) => isFieldValid(value, fieldName);

  @override
  void onSelectedAccountTypeChanged(AccountType? newType) {
    accountType = newType!;
    accountController.update();
  }

  @override
  Rx<AccountType> get selectedAccountType => accountType.obs;
}
