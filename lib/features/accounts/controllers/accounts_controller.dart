import 'dart:developer';

import 'package:ba3_bs_mobile/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs_mobile/core/router/app_routes.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/dialogs/account_selection_dialog_content.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../cheques/controllers/cheques/cheques_details_controller.dart';
import '../../floating_window/services/overlay_service.dart';
import '../../patterns/controllers/pattern_controller.dart';
import '../data/models/account_model.dart';
import '../data/repositories/accounts_repository.dart';

class AccountsController extends GetxController with AppNavigator {
  final AccountsRepository _accountsRepository;

  AccountsController(this._accountsRepository);

  List<AccountModel> accounts = [];

  bool isLoading = true;

  Map<Account, AccountModel> selectedAccounts = {};

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  // Fetch materials from the repository
  void fetchAccounts() {
    try {
      accounts = _accountsRepository.getAllAccounts();
    } catch (e) {
      debugPrint('Error in fetchAccounts($e)');
    } finally {
      isLoading = false;
      update();
    }
  }

  void navigateToAllAccountsScreen() {
    to(AppRoutes.showAllAccountsScreen);
  }

  void navigateToAccountDetailsScreen(String accountId) {
    to(AppRoutes.showAccountDetailsScreen, arguments: accountId);
  }

  List<AccountModel> searchAccountsByNameOrCode(text) {
    if (accounts.isEmpty) {
      log('Accounts isEmpty');
      fetchAccounts();
    }

    return accounts
        .where((item) => item.accName!.toLowerCase().contains(text.toLowerCase()) || item.accCode!.contains(text))
        .toList();
  }

  Map<String, AccountModel> mapAccountsByName(String query) {
    final resultMap = <String, AccountModel>{};
    for (var account in searchAccountsByNameOrCode(query)) {
      resultMap[account.accName!] = AccountModel(id: account.id, accName: account.accName);
    }
    return resultMap;
  }

  String getAccountNameById(String? accountId) {
    if (accountId == null || accountId.isEmpty) return '';
    return accounts.where((account) => account.id == accountId).firstOrNull?.accName ?? '';
  }

  String getAccountIdByName(String? accountName) {
    if (accountName == null || accountName.isEmpty) return '';
    return accounts.where((account) => account.accName == accountName).firstOrNull?.id ?? '';
  }

  AccountModel? getAccountModelByName(String text) {
    if (text != '') {
      final AccountModel accountModel = accounts
          .firstWhere((item) => item.accName!.toLowerCase() == text.toLowerCase() || item.accCode == text, orElse: () {
        return AccountModel(accName: null);
      });
      if (accountModel.accName == null) {
        return null;
      } else {
        return accountModel;
      }
    }
    return null;
  }

  AccountModel? getAccountModelById(id) {
    if (!(id == null || id == '')) {
      final AccountModel accountModel = accounts.firstWhere((item) => item.id == id, orElse: () {
        return AccountModel(accName: null);
      });
      if (accountModel.accName == null) {
        return null;
      } else {
        return accountModel;
      }
    }
    return null;
  }

  List<AccountModel> getAccounts(String query) => searchAccountsByNameOrCode(query);

  List<String> getAccountChildren(String? accountId) {
    if (accountId == null || accountId.isEmpty) return [];

    return accounts.where((account) => account.accParentGuid == accountId).map((child) => child.accName ?? '').toList();
  }

  void openAccountSelectionDialog({
    required String query,
    required BuildContext context,
    TextEditingController? textEditingController,
    bool fromAddBill = false,
    bool isCustomerAccount = false,
    bool isFirstAccountCheque = false,
    BondDetailsController? bondDetailsController,
    ChequesDetailsController? chequesDetailsController,
    IBillController? billController,
  }) {
    List<AccountModel> searchedAccounts = getAccounts(query);
    AccountModel? selectedAccountModel;

    if (searchedAccounts.length == 1) {
      // Single match
      selectedAccountModel = searchedAccounts.first;
      if (bondDetailsController != null) bondDetailsController.setAccount(searchedAccounts.first);
      if (chequesDetailsController != null) {
        isFirstAccountCheque
            ? chequesDetailsController.setFirstAccount(searchedAccounts.first)
            : chequesDetailsController.setTowAccount(searchedAccounts.first);
      }

      if (textEditingController != null) {
        final BillAccounts? billAccounts = read<PatternController>().controllerToBillAccountsMap[textEditingController];

        if (billAccounts != null) {
          selectedAccounts[billAccounts] = selectedAccountModel;
        }

        if (isCustomerAccount) {
          if (fromAddBill) {
            log('fromAddBill');
            billController!.updateCustomerAccount(selectedAccountModel);
          } else {
            log('BillDetailsController');
            billController!.updateCustomerAccount(selectedAccountModel);
          }
        }

        textEditingController.text = selectedAccountModel.accName!;
      }
    } else if (searchedAccounts.isNotEmpty) {
      OverlayService.showDialog(
        context: context,
        title: 'أختر الحساب',
        content: AccountSelectionDialogContent(
          accounts: searchedAccounts,
          onAccountTap: (selectedAccount) {
            OverlayService.back();

            // Set the selected account to the model
            selectedAccountModel = selectedAccount;

            // Callback for parent function with selected account

            if (selectedAccountModel != null && textEditingController != null) {
              if (bondDetailsController != null) bondDetailsController.setAccount(selectedAccount);
              if (chequesDetailsController != null) {
                isFirstAccountCheque
                    ? chequesDetailsController.setFirstAccount(selectedAccount)
                    : chequesDetailsController.setTowAccount(selectedAccount);
              }

              final BillAccounts? billAccounts =
                  read<PatternController>().controllerToBillAccountsMap[textEditingController];

              if (billAccounts != null) {
                selectedAccounts[billAccounts] = selectedAccountModel!;
              }

              if (isCustomerAccount) {
                if (fromAddBill) {
                  log('fromAddBill');
                  billController!.updateCustomerAccount(selectedAccountModel);
                } else {
                  log('InvoiceController');
                  billController!.updateCustomerAccount(selectedAccountModel);
                }
              }

              textEditingController.text = selectedAccountModel!.accName!;
            }
          },
        ),
        onCloseCallback: () {
          log('Account Selection Dialog Closed.');
        },
      );
    } else {
      // No matches
      AppUIUtils.showErrorSnackBar(title: 'فحص الحسابات', message: 'هذا الحساب غير موجود');
    }
  }
}
