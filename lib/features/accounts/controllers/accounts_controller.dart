import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/services/json_file_operations/implementations/import_export_repo.dart';
import 'package:ba3_bs_mobile/features/accounts/service/account_from_handler.dart';
import 'package:ba3_bs_mobile/features/accounts/ui/screens/add_account_screen.dart';
import 'package:ba3_bs_mobile/features/accounts/ui/screens/all_accounts_screen.dart';
import 'package:ba3_bs_mobile/features/customer/controllers/customers_controller.dart';
import 'package:ba3_bs_mobile/features/customer/data/models/customer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/dialogs/account_selection_dialog_content.dart';
import '../../../core/dialogs/customer_selection_dialog_content.dart';
import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../floating_window/services/overlay_service.dart';
import '../data/models/account_model.dart';
import '../service/account_service.dart';

class AccountsController extends GetxController with AppNavigator, FloatingLauncher {
  final BulkSavableDatasourceRepository<AccountModel> _accountsFirebaseRepo;

  final ImportExportRepository<AccountModel> _jsonImportExportRepo;

  AccountsController(this._jsonImportExportRepo, this._accountsFirebaseRepo);

  List<AccountModel> accounts = [];
  AccountModel? selectedAccount;

  bool get isEditAccount => selectedAccount == null ? false : true;

  late AccountFromHandler accountFromHandler;
  late AccountService accountService;

  final showAddCustomerForm = false.obs;
  final newCustomerNameController = TextEditingController();
  final newCustomerPhoneController = TextEditingController();
  final addedCustomers = <CustomerModel>[].obs;

  void setAccountParent(AccountModel accountModel) {
    accountFromHandler.accountParentModel = accountModel;
    accountFromHandler.accParentName.text = accountModel.accName!;
  }

  void initializer() {
    accountFromHandler = AccountFromHandler();
    accountService = AccountService();
  }

  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    log('onInit fetchAccounts');
    read<CustomersController>().fetchCustomers();
    fetchAccounts();
    initializer();
  }

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
      (savedAccounts) {
        if (savedAccounts.isNotEmpty) {
          AppUIUtils.onSuccess('تم رفع ${savedAccounts.length} حساب بنجاح');
        }
      },
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
        (fetchedAccounts) => _handelFetchAllAccountsFromLocalSuccess(fetchedAccounts),
      );
    }

    update();
  }

  void _handelFetchAllAccountsFromLocalSuccess(List<AccountModel> fetchedAccounts) async {
    log("fetchedAccounts length ${fetchedAccounts.length}");
    log('current accounts length is ${accounts.length}');

    final newAccounts = fetchedAccounts.subtract(accounts, (account) => account.accName);
    log('newAccounts length is ${newAccounts.length}');

    if (newAccounts.isNotEmpty) {
      await addAccounts(newAccounts);
      accounts.assignAll(newAccounts);
    }
  }

  Future<void> fetchAccounts() async {
    final result = await _accountsFirebaseRepo.getAll();

    result.fold(
      (error) => AppUIUtils.onFailure(error.message),
      (fetchedAccount) => accounts = fetchedAccount,
    );

    isLoading = false;
    update();
  }

  void navigateToAllAccountsScreen(BuildContext context) =>
      launchFloatingWindow(context: context, minimizedTitle: ApiConstants.accounts.tr, floatingScreen: AllAccountScreen());

  void navigateToFinalAccountsScreen(BuildContext context) {
    to(AppRoutes.finalAccountsScreen);
  }

  void navigateToAddOrUpdateAccountScreen({String? accountId, required BuildContext context}) {
    if (accountId != null) {
      selectedAccount = getAccountModelById(accountId);
    } else {
      selectedAccount = null;
    }
    updateSelectedCustomers(selectedAccount?.accCustomer);

    accountFromHandler.init(accountModel: selectedAccount);

    launchFloatingWindow(context: context, minimizedTitle: ApiConstants.accounts.tr, floatingScreen: AddAccountScreen());

    // to(AppRoutes.addAccountScreen);
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

    var partialMatch = accounts.where(
      (acc) {
        String accName = acc.accName!.toLowerCase();
        return searchParts.every((part) => accName.contains(part)); // التحقق من أن جميع أجزاء النص المدخل موجودة في الاسم
      },
    );

    if (partialMatch.length == 1) {
      return [partialMatch.first]; // إرجاع أول تطابق جزئي متتابع
    } else if (partialMatch.length > 1) {
      return partialMatch.toList();
    }

    return accounts.where((item) => item.accName!.toLowerCase().startsWith(text.toLowerCase()) || item.accCode!.startsWith(text)).toList();
  }

  List<CustomerModel> searchAccountsCustomerByName(String text, List<String>? customerIds) {
    List<CustomerModel> customerAccounts =
        read<CustomersController>().customers.where((cu) => customerIds?.contains(cu.id) ?? false).toList();
    if (customerAccounts.isEmpty) {
      log('customerAccounts isEmpty');
    }

    // تنظيف النص المدخل من الفراغات الزائدة وتحويله إلى قائمة من الكلمات
    List<String> searchParts = text.toLowerCase().split(' ');

    // البحث عن تطابق كامل أولاً
    var exactMatch = customerAccounts.firstWhereOrNull(
      (item) => item.name?.toLowerCase() == text.toLowerCase(),
    );

    if (exactMatch != null) {
      return [exactMatch]; // إرجاع الحساب المطابق فقط
    }

    var partialMatch = customerAccounts.where(
      (acc) {
        String accName = acc.name!.toLowerCase();
        return searchParts.every((part) => accName.contains(part)); // التحقق من أن جميع أجزاء النص المدخل موجودة في الاسم
      },
    );

    if (partialMatch.length == 1) {
      return [partialMatch.first]; // إرجاع أول تطابق جزئي متتابع
    } else if (partialMatch.length > 1) {
      return partialMatch.toList();
    }

    return customerAccounts.where((item) => item.name!.toLowerCase().startsWith(text.toLowerCase())).toList();
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
    String? accountID;

    if (accountName == null || accountName.isEmpty) accountID = '';
    accountID = accounts.where((account) => account.accName == accountName).firstOrNull?.id ?? '';
    // if (accountID == '') log('getAccountIdByName with $accountName is null');
    return accountID;
  }

  AccountModel? getAccountModelByName(String text) {
    if (text != '') {
      final AccountModel accountModel =
          accounts.firstWhere((item) => item.accName!.toLowerCase() == text.toLowerCase() || item.accCode == text, orElse: () {
        log('getAccountModelByName is null with  $text');
        return AccountModel(accName: null);
      });
      if (accountModel.accName == null) {
        log('getAccountModelByName is null with  $text');

        return null;
      } else {
        return accountModel;
      }
    }
    log('getAccountModelByName is null with  $text');

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

  List<CustomerModel> getCustomersAccounts(String query, List<String>? customerIds) => searchAccountsCustomerByName(query, customerIds);

  List<String> getAccountChildrenNames(String? accountId) {
    if (accountId == null || accountId.isEmpty) return [];

    return accounts.where((account) => account.accParentGuid == accountId).map((child) => child.accName ?? '').toList();
  }

  List<AccountModel> getAccountChildren(String? accountId) {
    if (accountId == null || accountId.isEmpty) return [];

    return accounts.where((account) => account.accParentGuid == accountId).toList();
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

  Future<CustomerModel?> openCustomerSelectionDialog({
    required String query,
    required BuildContext context,
    required String? accountId,
  }) async {
    if (accountId == null) return null;
    AccountModel? accountModel = getAccountModelById(accountId);
    List<CustomerModel> searchedCustomers = getCustomersAccounts(query, accountModel?.accCustomer);
    CustomerModel? selectedCustomerModel;

    if (searchedCustomers.length == 1) {
      // Single match
      selectedCustomerModel = searchedCustomers.first;
    } else if (searchedCustomers.isNotEmpty) {
      await OverlayService.showDialog(
        context: context,
        title: 'أختر الحساب',
        content: CustomerSelectionDialogContent(
          customers: searchedCustomers,
          onCustomerTap: (selectedAccount) {
            OverlayService.back();
            selectedCustomerModel = selectedAccount;
          },
        ),
        onCloseCallback: () {
          log('Customer Selection Dialog Closed.');
        },
      );
    } else {
      AppUIUtils.showErrorSnackBar(title: 'فحص الزبائن', message: 'هذا الزبون غير موجود');
    }

    return selectedCustomerModel;
  }

  void saveOrUpdateAccount() async {
    if (!_validateInput()) return;

    final updatedAccountModel = _createUpdatedAccountModel();

    if (updatedAccountModel == null) {
      AppUIUtils.onFailure('من فضلك أدخل ');
      return;
    }
    await _saveAccountWithCustomers(updatedAccountModel);
  }

  bool _validateInput() => accountFromHandler.validate();

  AccountModel? _createUpdatedAccountModel() => accountService.createAccountModel(
        accountModel: selectedAccount,
        accName: accountFromHandler.nameController.text,
        accCode: accountFromHandler.codeController.text,
        accLatinName: accountFromHandler.latinNameController.text,
        accType: accountFromHandler.accountType,
        accParentGuid: accountFromHandler.accountParentModel?.id,
        accParentName: accountFromHandler.accountParentModel?.accName,
        accCheckDate: Timestamp.now().toDate(),
      );

  Future<void> _saveAccountWithCustomers(AccountModel updatedAccountModel) async {
    if (addedCustomers.isNotEmpty) {
      final result = await read<CustomersController>().addCustomers(addedCustomers);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (savedCustomers) => _onSaveCustomersSuccess(
          updatedAccountModel: updatedAccountModel,
          savedCustomers: savedCustomers,
        ),
      );
    } else {
      await _onSaveCustomersSuccess(updatedAccountModel: updatedAccountModel);
    }
  }

  Future<void> _onSaveCustomersSuccess({
    required AccountModel updatedAccountModel,
    List<CustomerModel>? savedCustomers,
  }) async {
    final accountWithCustomers = _attachSavedCustomers(updatedAccountModel, savedCustomers);

    final result = await _accountsFirebaseRepo.save(accountWithCustomers);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) => AppUIUtils.onSuccess('تم اضافة الحساب بنجاح'),
    );
  }

  AccountModel _attachSavedCustomers(AccountModel updatedAccountModel, List<CustomerModel>? savedCustomers) {
    if (savedCustomers == null) return updatedAccountModel;

    for (final c in savedCustomers) {
      log('customer id ${c.id}');
    }
    final savedCustomerIds = savedCustomers.map((customer) => customer.id!).toList();
    return updatedAccountModel.copyWith(accCustomer: savedCustomerIds);
  }

  void deleteAccount() async {
    if (isEditAccount) {
      final result = await _accountsFirebaseRepo.delete(selectedAccount!.id!);
      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (_) {
          AppUIUtils.onSuccess('تم حذف الحساب بنجاح');
        },
      );
    }
  }

  Rx<VatEnums> selectedVat = VatEnums.withVat.obs;

  void toggleAddCustomerForm() {
    showAddCustomerForm.value = !showAddCustomerForm.value;
  }

  void addNewCustomer() {
    if (newCustomerNameController.text.isNotEmpty && newCustomerPhoneController.text.isNotEmpty) {
      addedCustomers.add(
        CustomerModel(
          name: newCustomerNameController.text,
          phone1: newCustomerPhoneController.text,
          cusVatGuid: selectedVat.value.taxGuid,
        ),
      );
      newCustomerNameController.clear();
      newCustomerPhoneController.clear();
      showAddCustomerForm.value = false;
    } else {
      AppUIUtils.onFailure('يرجى تعبئة جميع الحقول');
    }
  }

  void deleteCustomer({required CustomerModel customer}) {
    addedCustomers.remove(customer);
  }

  void onSelectedVatChanged(VatEnums? newVat) {
    if (newVat != null) {
      selectedVat.value = newVat;
    }
  }

  updateSelectedCustomers(List<String>? accCustomer) {
    if (accCustomer == null || accCustomer.isEmpty) {
      addedCustomers.clear();
    } else {
      setSelectedCustomers(accCustomer);
    }
  }

  /// Handle multiple customer selection
  void setSelectedCustomers(List<String> customerIds) {
    addedCustomers.assignAll(
      read<CustomersController>().customers.where(
            (customer) => customerIds.contains(customer.id),
          ),
    );
  }
}