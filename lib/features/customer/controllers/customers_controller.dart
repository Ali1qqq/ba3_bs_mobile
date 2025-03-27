import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import 'package:ba3_bs_mobile/core/services/json_file_operations/implementations/import/import_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/error/failure.dart';
import '../../../core/services/firebase/implementations/services/firestore_uploader.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../data/models/customer_model.dart';

class CustomersController extends GetxController with AppNavigator {
  final ImportRepository<CustomerModel> _customerImportRepo;
  final BulkSavableDatasourceRepository<CustomerModel> _customersFirestoreRepo;

  CustomersController(this._customersFirestoreRepo, this._customerImportRepo);

  List<CustomerModel> customers = [];

  // bool get isFromHandler => selectedCustomer == null ? false : true;

  // late AccountFromHandler accountFromHandler;
  // late AccountService accountService;
  //
  // void setAccountParent(CustomerModel customerModel) {
  //   accountFromHandler.accountParentModel = customerModel;
  //   accountFromHandler.accParentName.text = customerModel.accName!;
  //   update();
  // }
  //
  // void initializer() {
  //   accountFromHandler = AccountFromHandler();
  //   accountService = AccountService();
  // }

  bool isLoading = true;

  // Fetch materials from the repository
  //
  // Future<void> addAccount(AccountModel seller) async {
  //   final result = await _accountsFirebaseRepo.save(seller);
  //
  //   result.fold(
  //     (failure) => AppUIUtils.onFailure(failure.message),
  //     (fetchedAccounts) {},
  //   );
  // }
  //

  Future<Either<Failure, List<CustomerModel>>> addCustomers(List<CustomerModel> customers) async =>
      await _customersFirestoreRepo.saveAll(customers);

  // Initialize a progress observable
  RxDouble uploadProgress = 0.0.obs;

  Future<void> fetchAllCustomersFromLocal() async {
    log('fetchAllCustomersFromLocal');

    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = await _customerImportRepo.importXmlFile(file);
      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (customersFromLocal) {
          customers.assignAll(customersFromLocal);
          log('customersFromLocal length: ${customersFromLocal.length}');
          FirestoreUploader firestoreUploader = FirestoreUploader();
          firestoreUploader.concurrently(
            data: customersFromLocal.map((item) => item.toJson()).toList(),
            collectionPath: ApiConstants.customers,
            onProgress: (progress) {
              uploadProgress.value = progress; // Update progress
              log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
            },
          );

          //  addAccounts(accounts);
        },
      );
    }

    update();
  }

  Future<void> fetchCustomers() async {
    final result = await _customersFirestoreRepo.getAll();

    result.fold(
      (error) => AppUIUtils.onFailure(error.message),
      (fetchedCustomers) => customers = fetchedCustomers,
    );
  }

  CustomerModel? getCustomerById(String? billCustomerId) {
    if (billCustomerId == null || billCustomerId.isEmpty) return null;

    return customers.where((customer) => customer.id == billCustomerId).firstOrNull;
  }

//
// void navigateToAllAccountsScreen() {
//   to(AppRoutes.showAllAccountsScreen);
// }
//
// void navigateToAddOrUpdateAccountScreen({String? accountId}) {
//   selectedAccount = null;
//   if (accountId != null) selectedAccount = getAccountModelById(accountId);
//
//   accountFromHandler.init(accountModel: selectedAccount);
//
//   to(AppRoutes.addAccountScreen);
// }
//
// List<AccountModel> searchAccountsByNameOrCode(text) {
//   if (accounts.isEmpty) {
//     log('Accounts isEmpty');
//     // fetchAccounts();
//   }
//
//   return accounts.where((item) => item.accName!.toLowerCase().contains(text.toLowerCase()) || item.accCode!.contains(text)).toList();
// }
//
// Map<String, AccountModel> mapAccountsByName(String query) {
//   final resultMap = <String, AccountModel>{};
//   for (var account in searchAccountsByNameOrCode(query)) {
//     resultMap[account.accName!] = AccountModel(id: account.id, accName: account.accName);
//   }
//   return resultMap;
// }
//
// String getAccountNameById(String? accountId) {
//   if (accountId == null || accountId.isEmpty) return '';
//   return accounts.where((account) => account.id == accountId).firstOrNull?.accName ?? accountId;
// }
//
// String getAccountIdByName(String? accountName) {
//   if (accountName == null || accountName.isEmpty) return '';
//   return accounts.where((account) => account.accName == accountName).firstOrNull?.id ?? '';
// }
//
// AccountModel? getAccountModelByName(String text) {
//   if (text != '') {
//     final AccountModel accountModel =
//         accounts.firstWhere((item) => item.accName!.toLowerCase() == text.toLowerCase() || item.accCode == text, orElse: () {
//       return AccountModel(accName: null);
//     });
//     if (accountModel.accName == null) {
//       return null;
//     } else {
//       return accountModel;
//     }
//   }
//   return null;
// }
//
// AccountModel? getAccountModelById(id) {
//   if (!(id == null || id == '')) {
//     final AccountModel accountModel = accounts.firstWhere((item) => item.id == id, orElse: () {
//       return AccountModel(accName: null);
//     });
//     if (accountModel.accName == null) {
//       return null;
//     } else {
//       return accountModel;
//     }
//   }
//   return null;
// }
//
// List<AccountModel> getAccounts(String query) => searchAccountsByNameOrCode(query);
//
// List<String> getAccountChildren(String? accountId) {
//   if (accountId == null || accountId.isEmpty) return [];
//
//   return accounts.where((account) => account.accParentGuid == accountId).map((child) => child.accName ?? '').toList();
// }
//
// Future<AccountModel?> openAccountSelectionDialog({
//   required String query,
//   required BuildContext context,
// }) async {
//   List<AccountModel> searchedAccounts = getAccounts(query);
//   AccountModel? selectedAccountModel;
//
//   if (searchedAccounts.length == 1) {
//     // Single match
//     selectedAccountModel = searchedAccounts.first;
//   } else if (searchedAccounts.isNotEmpty) {
//     await OverlayService.showDialog(
//       context: context,
//       title: 'أختر الحساب',
//       content: AccountSelectionDialogContent(
//         accounts: searchedAccounts,
//         onAccountTap: (selectedAccount) {
//           OverlayService.back();
//           selectedAccountModel = selectedAccount;
//         },
//       ),
//       onCloseCallback: () {
//         log('Account Selection Dialog Closed.');
//       },
//     );
//   } else {
//     AppUIUtils.showErrorSnackBar(title: 'فحص الحسابات', message: 'هذا الحساب غير موجود');
//   }
//
//   return selectedAccountModel;
// }
//
// void saveOrUpdateAccount() async {
//   // Validate the input before proceeding
//   if (!accountFromHandler.validate()) return;
//
//   // Create a material model based on the user input
//   final updatedAccountModel = accountService.createAccountModel(
//     accountModel: selectedAccount,
//     accName: accountFromHandler.nameController.text,
//     accCode: accountFromHandler.codeController.text,
//     accLatinName: accountFromHandler.latinNameController.text,
//     accType: accountFromHandler.accountType,
//     accParentGuid: accountFromHandler.accountParentModel?.id,
//     accParentName: accountFromHandler.accountParentModel?.accName,
//     accCheckDate: Timestamp.now().toDate(),
//   );
//
//   // Handle null material model
//   if (updatedAccountModel == null) {
//     AppUIUtils.onFailure('');
//     return;
//   }
//   // Save changes and handle results
//   final result = await _accountsFirebaseRepo.save(updatedAccountModel);
//
//   result.fold(
//     (failure) => AppUIUtils.onFailure(failure.message),
//     (_) => AppUIUtils.onSuccess('تم اضافة الحساب بنجاح'),
//   );
//
//   update();
// }
//
// void deleteAccount() async {
//   if (isFromHandler) {
//     final result = await _accountsFirebaseRepo.delete(selectedAccount!.id!);
//     result.fold(
//       (failure) => AppUIUtils.onFailure(failure.message),
//       (_) {
//         AppUIUtils.onSuccess("تم حذف الحساب بنجاح");
//       },
//     );
//   }
// }
}