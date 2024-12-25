import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../patterns/data/models/bill_type_model.dart';

class AccountHandler {
  BillTypeModel? updateBillTypeAccounts(
    BillTypeModel billTypeModel,
    Map<Account, AccountModel> selectedAdditionsDiscountAccounts,
    AccountModel? selectedCustomerAccount,
    StoreAccount selectedStore,
  ) {
    final updatedAccounts = {...billTypeModel.accounts ?? {}};

    if (updateAdditionsDiscountNeeded(selectedAdditionsDiscountAccounts)) {
      _updateDiscountAndAdditionAccounts(selectedAdditionsDiscountAccounts, updatedAccounts);
    }

    if (updateCustomerNeeded(selectedCustomerAccount, updatedAccounts)) {
      _updateCachesAccount(selectedCustomerAccount!, updatedAccounts);
    }

    if (updateStoreNeeded(selectedStore)) {
      _updateStoreAccount(selectedStore, updatedAccounts);
    }

    return billTypeModel.copyWith(accounts: updatedAccounts);
  }

  bool updateCustomerNeeded(AccountModel? selectedCustomerAccount, Map<Account, AccountModel> updatedAccounts) =>
      selectedCustomerAccount != null && updatedAccounts[BillAccounts.caches]?.id != selectedCustomerAccount.id;

  bool updateStoreNeeded(StoreAccount selectedStore) => selectedStore != StoreAccount.main;

  bool updateAdditionsDiscountNeeded(Map<Account, AccountModel> selectedAccounts) => selectedAccounts.isNotEmpty;

  // Update discount and addition accounts
  void _updateDiscountAndAdditionAccounts(
      Map<Account, AccountModel> selectedAccounts, Map<Account, AccountModel> updatedAccounts) {
    if (selectedAccounts.containsKey(BillAccounts.discounts)) {
      updatedAccounts[BillAccounts.discounts] = selectedAccounts[BillAccounts.discounts]!;
    }
    if (selectedAccounts.containsKey(BillAccounts.additions)) {
      updatedAccounts[BillAccounts.additions] = selectedAccounts[BillAccounts.additions]!;
    }
  }

  // Update caches account if selectedCustomerAccount is not null and differs from the current cache
  void _updateCachesAccount(AccountModel selectedCustomerAccount, Map<Account, AccountModel> updatedAccounts) {
    updatedAccounts[BillAccounts.caches] = selectedCustomerAccount;
  }

  // Update store account if selectedStore is not null and differs from the current store
  void _updateStoreAccount(StoreAccount? selectedStore, Map<Account, AccountModel> updatedAccounts) {
    updatedAccounts[BillAccounts.store] = selectedStore!.toStoreAccountModel;
  }
}
