import 'package:ba3_bs_mobile/features/patterns/controllers/pattern_controller.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/validators/app_validator.dart';
import '../../../core/interfaces/i_store_selection_handler.dart';
import '../../accounts/controllers/accounts_controller.dart';
import '../../accounts/data/models/account_model.dart';

class PatternFormHandler with AppValidator implements IStoreSelectionHandler {
  PatternController get patternController => read<PatternController>();

  AccountsController get accountsController => read<AccountsController>();

  final formKey = GlobalKey<FormState>();

  TextEditingController latinShortNameController = TextEditingController();
  TextEditingController latinFullNameController = TextEditingController();
  TextEditingController shortNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController giftsController = TextEditingController();
  TextEditingController exchangeForGiftsController = TextEditingController();
  TextEditingController discountsController = TextEditingController();
  TextEditingController materialsController = TextEditingController();
  TextEditingController additionsController = TextEditingController();
  TextEditingController cachesController = TextEditingController();
  TextEditingController storeController = TextEditingController();

  BillPatternType? selectedBillPatternType;

  BillTypeModel? selectedBillTypeModel;

  int? selectedColorValue;

  void initializeControllerToBillAccountsMap() {
    if (patternController.controllerToBillAccountsMap.isEmpty) {
      patternController.controllerToBillAccountsMap.addAll({
        giftsController: BillAccounts.gifts,
        exchangeForGiftsController: BillAccounts.exchangeForGifts,
        discountsController: BillAccounts.discounts,
        materialsController: BillAccounts.materials,
        additionsController: BillAccounts.additions,
        cachesController: BillAccounts.caches,
        storeController: BillAccounts.store,
      });
    }
  }

  Map<Account, AccountModel> selectedAccounts = {};

  set setSelectedAccounts(Map<Account, AccountModel>? accounts) {
    selectedAccounts = accounts ?? {};
  }

  void populateBillTypeAccounts(BillTypeModel billType) {
    // Ensure the map is populated before use
    initializeControllerToBillAccountsMap();

    // Set the selected accounts in the accounts controller
    setSelectedAccounts = billType.accounts;

    final accounts = billType.accounts;

    patternController.controllerToBillAccountsMap.forEach((controller, accountType) {
      // Update the controller text based on the account map
      if (accounts != null && accounts.containsKey(accountType)) {
        controller.text = accounts[accountType]?.accName ?? '';
      } else {
        controller.clear();
      }
    });
  }

  void init(BillTypeModel? billType) {
    if (billType != null) {
      // Determine the bill pattern type from the label
      final billPatternType = BillPatternType.byValue(billType.billTypeLabel!);

      // Autofill pattern controllers based on the bill pattern type
      patternController.autoFillControllers(billPatternType);

      // Populate the bill type accounts
      populateBillTypeAccounts(billType);

      // Set the selected bill type
      selectedBillPatternType = billPatternType;

      selectedBillTypeModel = billType;
      selectedColorValue = billType.color!;
    } else {
      // Clear all controllers and reset the state
      clear();

      // Initialize the controller-to-bill-accounts map
      initializeControllerToBillAccountsMap();

      setSelectedAccounts = {};

      // Reset the selected bill type
      selectedBillPatternType = null;

      selectedBillTypeModel = null;
      selectedColorValue = Colors.red.value;
    }
  }

  void clear() {
    shortNameController.clear();
    fullNameController.clear();
    latinShortNameController.clear();
    latinFullNameController.clear();
    giftsController.clear();
    exchangeForGiftsController.clear();
    discountsController.clear();
    materialsController.clear();
    additionsController.clear();
    cachesController.clear();
    storeController.clear();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  // void dispose() {
  //   shortNameController.dispose();
  //   fullNameController.dispose();
  //   latinShortNameController.dispose();
  //   latinFullNameController.dispose();
  //   giftsController.dispose();
  //   exchangeForGiftsController.dispose();
  //   discountsController.dispose();
  //   materialsController.dispose();
  //   additionsController.dispose();
  //   cachesController.dispose();
  //   storeController.dispose();
  // }

  @override
  Rx<StoreAccount> selectedStore = StoreAccount.main.obs;

  @override
  void onSelectedStoreChanged(StoreAccount? newStore) {
    if (newStore != null) {
      selectedStore.value = newStore;
    }
  }

  void onSelectedTypeChanged(BillPatternType? newType) {
    if (newType != null) {
      selectedBillPatternType = newType;
      patternController.autoFillControllers(newType);
      patternController.update();
    }
  }

  void onMainColorChanged(int? newColorValue) {
    if (newColorValue != null) {
      selectedColorValue = newColorValue;
      patternController.update();
    }
  }

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);
}
