import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../controllers/accounts_controller.dart';
import '../data/models/account_model.dart';

class GroupAccountsByFinalCategoryUseCase {
  Map<FinalAccounts, List<AccountModel>> execute() {
    final accounts = read<AccountsController>().accounts;

    // Initialize groups for each final account type
    final accountGroups = {
      FinalAccounts.tradingAccount: <AccountModel>[],
      FinalAccounts.profitAndLoss: <AccountModel>[],
      FinalAccounts.balanceSheet: <AccountModel>[],
    };

    // Single pass grouping
    for (final account in accounts) {
      if (account.accFinalGuid == FinalAccounts.tradingAccount.accPtr) {
        accountGroups[FinalAccounts.tradingAccount]!.add(account);
      } else if (account.accFinalGuid == FinalAccounts.profitAndLoss.accPtr) {
        accountGroups[FinalAccounts.profitAndLoss]!.add(account);
      } else if (account.accFinalGuid == FinalAccounts.balanceSheet.accPtr) {
        accountGroups[FinalAccounts.balanceSheet]!.add(account);
      }
    }

    return accountGroups;
  }
}
