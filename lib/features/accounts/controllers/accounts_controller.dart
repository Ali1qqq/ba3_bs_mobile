import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/core/router/app_routes.dart';
import 'package:ba3_bs_mobile/core/services/json_file_operations/implementations/import_export_repo.dart';
import 'package:ba3_bs_mobile/features/accounts/service/account_from_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/dialogs/account_selection_dialog_content.dart';
import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../floating_window/services/overlay_service.dart';
import '../data/models/account_model.dart';
import '../service/account_service.dart';

class AccountsController extends GetxController with AppNavigator {
  final BulkSavableDatasourceRepository<AccountModel> _accountsFirebaseRepo;

  final ImportExportRepository<AccountModel> _jsonImportExportRepo;

  AccountsController(this._jsonImportExportRepo, this._accountsFirebaseRepo);

  List<AccountModel> accounts = [];
  AccountModel? selectedAccount;

  bool get isFromHandler => selectedAccount == null ? false : true;

  late AccountFromHandler accountFromHandler;
  late AccountService accountService;

  void setAccountParent(AccountModel accountModel) {
    accountFromHandler.accountParentModel = accountModel;
    accountFromHandler.accParentName.text = accountModel.accName!;
    update();
  }

  void initializer() {
    accountFromHandler = AccountFromHandler();
    accountService = AccountService();
  }

  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
    initializer();
  }

  // Fetch materials from the repository

  Future<void> addAccount(AccountModel seller) async {
    final result = await _accountsFirebaseRepo.save(seller);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedAccounts) {},
    );
  }

  Future<void> addAccounts(List<AccountModel> accounts) async {
    final result = await _accountsFirebaseRepo.saveAll(accounts);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedAccounts) {},
    );
  }

  Future<void> fetchAllAccountsFromLocal() async {
    log('fetchAllAccountsFromLocal');

    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = await _jsonImportExportRepo.importXmlFile(file);
      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedAccounts) {
          log("fetchedAccounts length ${fetchedAccounts.length}");
          log(fetchedAccounts.last.toJson().toString());

          accounts.assignAll(fetchedAccounts);
          addAccounts(accounts);
        },
      );
    }

    update();
  }

  void fetchAccounts() async {
    final result = await _accountsFirebaseRepo.getAll();

    result.fold(
      (error) => AppUIUtils.onFailure(error.message),
      (fetchedAccount) => accounts = fetchedAccount,
    );

    isLoading = false;
    update();
  }

  void navigateToAllAccountsScreen() {
    to(AppRoutes.showAllAccountsScreen);
  }

  void navigateToAddOrUpdateAccountScreen({String? accountId}) {
    selectedAccount = null;
    if (accountId != null) selectedAccount = getAccountModelById(accountId);

    accountFromHandler.init(accountModel: selectedAccount);
    to(AppRoutes.addAccountScreen);
  }

  List<AccountModel> searchAccountsByNameOrCode(String text) {
    if (accounts.isEmpty) {
      log('Accounts isEmpty');
    }

    // تنظيف النص المدخل من الفراغات الزائدة وتحويله إلى قائمة من الكلمات
    List<String> searchParts = text.toLowerCase().split(' ');

    // البحث عن تطابق كامل أولاً
    var exactMatch = accounts.firstWhereOrNull(
      (item) => item.accName?.toLowerCase() == text.toLowerCase() || item.accCode == text,
    );

    if (exactMatch != null) {
      return [exactMatch]; // إرجاع الحساب المطابق فقط
    }

    // البحث عن تطابق جزئي متتابع
    var partialMatch = accounts.firstWhereOrNull(
      (item) {
        String name = item.accName!.toLowerCase();
        return searchParts.every((part) => name.contains(part)); // التحقق من أن جميع أجزاء النص المدخل موجودة في الاسم
      },
    );

    if (partialMatch != null) {
      return [partialMatch]; // إرجاع أول تطابق جزئي متتابع
    }

    // البحث العادي عند عدم وجود تطابق متتابع
    return accounts.where((item) => item.accName!.toLowerCase().contains(text.toLowerCase()) || item.accCode!.contains(text)).toList();
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
    return accounts.where((account) => account.id == accountId).firstOrNull?.accName ?? accountId;
  }

  String getAccountIdByName(String? accountName) {
    if (accountName == null || accountName.isEmpty) return '';
    return accounts.where((account) => account.accName == accountName).firstOrNull?.id ?? '';
  }

  AccountModel? getAccountModelByName(String text) {
    if (text != '') {
      final AccountModel accountModel =
          accounts.firstWhere((item) => item.accName!.toLowerCase() == text.toLowerCase() || item.accCode == text, orElse: () {
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

  Future<AccountModel?> openAccountSelectionDialog({
    required String query,
    required BuildContext context,
  }) async {
    List<AccountModel> searchedAccounts = getAccounts(query);
    AccountModel? selectedAccountModel;

    if (searchedAccounts.length == 1) {
      // Single match
      selectedAccountModel = searchedAccounts.first;
    } else if (searchedAccounts.isNotEmpty) {
      await OverlayService.showDialog(
        context: context,
        title: 'أختر الحساب',
        content: AccountSelectionDialogContent(
          accounts: searchedAccounts,
          onAccountTap: (selectedAccount) {
            OverlayService.back();
            selectedAccountModel = selectedAccount;
          },
        ),
        onCloseCallback: () {
          log('Account Selection Dialog Closed.');
        },
      );
    } else {
      AppUIUtils.showErrorSnackBar(title: 'فحص الحسابات', message: 'هذا الحساب غير موجود');
    }

    return selectedAccountModel;
  }

  void saveOrUpdateAccount() async {
    // Validate the input before proceeding
    if (!accountFromHandler.validate()) return;

    // Create a material model based on the user input
    final updatedAccountModel = accountService.createAccountModel(
      accountModel: selectedAccount,
      accName: accountFromHandler.nameController.text,
      accCode: accountFromHandler.codeController.text,
      accLatinName: accountFromHandler.latinNameController.text,
      accType: accountFromHandler.accountType,
      accParentGuid: accountFromHandler.accountParentModel?.id,
      accParentName: accountFromHandler.accountParentModel?.accName,
      accCheckDate: Timestamp.now().toDate(),
    );

    // Handle null material model
    if (updatedAccountModel == null) {
      AppUIUtils.onFailure('');
      return;
    }
    log(updatedAccountModel.toJson().toString());
    /* // Save changes and handle results
    final result = await _accountsFirebaseRepo.save(updatedAccountModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) => AppUIUtils.onSuccess('تم اضافة الحساب بنجاح'),
    );*/

    update();
  }

  void deleteAccount() async {
    if (isFromHandler) {
      final result = await _accountsFirebaseRepo.delete(selectedAccount!.id!);
      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (_) {},
      );
    }
  }
}
