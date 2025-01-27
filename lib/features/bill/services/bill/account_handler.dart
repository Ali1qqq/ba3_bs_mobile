import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/discount_addition_account_model.dart';

class AccountHandler {
  BillTypeModel? updateBillTypeAccounts(
    BillTypeModel billTypeModel,
    Map<Account, List<DiscountAdditionAccountModel>> selectedAdditionsDiscountAccounts,
    AccountModel? selectedCustomerAccount,
    StoreAccount selectedStore,
  ) {
    final updatedAccounts = {...billTypeModel.accounts ?? {}};
    final updatedDiscountsAdditionsAccounts = {...billTypeModel.discountAdditionAccounts ?? {}};

    if (updateAdditionsDiscountNeeded(selectedAdditionsDiscountAccounts)) {
      _updateDiscountAndAdditionAccounts(selectedAdditionsDiscountAccounts, updatedDiscountsAdditionsAccounts);
    }

    if (updateCustomerNeeded(selectedCustomerAccount, updatedAccounts)) {
      _updateCachesAccount(selectedCustomerAccount!, updatedAccounts);
    }

    if (updateStoreNeeded(selectedStore)) {
      _updateStoreAccount(selectedStore, updatedAccounts);
    }

    return billTypeModel.copyWith(
      accounts: updatedAccounts,
      discountAdditionAccounts: updatedDiscountsAdditionsAccounts,
    );
  }

  bool updateCustomerNeeded(AccountModel? selectedCustomerAccount, Map<Account, AccountModel> updatedAccounts) =>
      selectedCustomerAccount != null && updatedAccounts[BillAccounts.caches]?.id != selectedCustomerAccount.id;

  bool updateStoreNeeded(StoreAccount selectedStore) => selectedStore != StoreAccount.main;

  bool updateAdditionsDiscountNeeded(Map<Account, List<DiscountAdditionAccountModel>> selectedAccounts) => selectedAccounts.isNotEmpty;

  // Update discount and addition accounts
  void _updateDiscountAndAdditionAccounts(
    Map<Account, List<DiscountAdditionAccountModel>> selectedDiscountsAdditionsAccounts,
    Map<Account, List<DiscountAdditionAccountModel>> defaultAccounts,
  ) {
    if (selectedDiscountsAdditionsAccounts.containsKey(BillAccounts.discounts)) {
      defaultAccounts[BillAccounts.discounts] = selectedDiscountsAdditionsAccounts[BillAccounts.discounts]!;
    }
    if (selectedDiscountsAdditionsAccounts.containsKey(BillAccounts.additions)) {
      defaultAccounts[BillAccounts.additions] = selectedDiscountsAdditionsAccounts[BillAccounts.additions]!;
    }
  }

  // Update caches account if selectedCustomerAccount is not null and differs from the current cache
  void _updateCachesAccount(AccountModel selectedCustomerAccount, Map<Account, AccountModel> defaultAccount) {
    defaultAccount[BillAccounts.caches] = selectedCustomerAccount;
  }

  // Update store account if selectedStore is not null and differs from the current store
  void _updateStoreAccount(StoreAccount? selectedStore, Map<Account, AccountModel> defaultAccount) {
    defaultAccount[BillAccounts.store] = selectedStore!.toStoreAccountModel;
  }
}
