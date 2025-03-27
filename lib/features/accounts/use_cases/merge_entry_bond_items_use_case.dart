import 'package:ba3_bs_mobile/core/helper/extensions/date_time/date_time_extensions.dart';

import '../../../core/helper/enums/enums.dart';
import '../../bond/data/models/entry_bond_model.dart';
import '../data/models/account_model.dart';
import '../service/account_statement_service.dart';

class MergeEntryBondItemsUseCase {
  final AccountStatementService _accountStatementService;

  MergeEntryBondItemsUseCase(this._accountStatementService);

  EntryBondItemModel? mergeTradingItems(Map<AccountEntity, List<EntryBondItems>> tradingAccountResult) {
    final allTradingItems = tradingAccountResult.values.expand((list) => list).toList();
    if (allTradingItems.isEmpty) return null;

    double totalDebit = 0.0;
    double totalCredit = 0.0;

    for (final entry in allTradingItems) {
      for (final item in entry.itemList) {
        final amount = item.amount ?? 0.0;
        if (item.bondItemType == BondItemType.debtor) {
          totalDebit += amount;
        } else {
          totalCredit += amount;
        }
      }
    }

    final finalAmount = totalDebit - totalCredit;
    return EntryBondItemModel(
      amount: finalAmount.abs(),
      bondItemType: finalAmount >= 0 ? BondItemType.debtor : BondItemType.creditor,
      date: DateTime.now().dayMonthYear,
      note: 'إجمالي حساب المتاجرة',
      account: AccountEntity(
        id: FinalAccounts.tradingAccount.accPtr,
        name: FinalAccounts.tradingAccount.accName,
      ),
    );
  }

  EntryBondItemModel? mergeProfitLossItems(
      Map<AccountEntity, List<EntryBondItems>> tradingAccountResult, Map<AccountEntity, List<EntryBondItems>> profitAndLossAccountResult) {
    final allItems = [...tradingAccountResult.values.expand((list) => list), ...profitAndLossAccountResult.values.expand((list) => list)];
    if (allItems.isEmpty) return null;

    double totalDebit = 0.0;
    double totalCredit = 0.0;

    for (final entry in allItems) {
      for (final item in entry.itemList) {
        final amount = item.amount ?? 0.0;
        if (item.bondItemType == BondItemType.debtor) {
          totalDebit += amount;
        } else {
          totalCredit += amount;
        }
      }
    }

    final finalAmount = totalDebit - totalCredit;
    return EntryBondItemModel(
      amount: finalAmount.abs(),
      bondItemType: finalAmount >= 0 ? BondItemType.debtor : BondItemType.creditor,
      date: _accountStatementService.formattedToday,
      note: 'إجمالي حساب الأرباح والخسائر',
      account: AccountEntity(
        id: FinalAccounts.profitAndLoss.accPtr,
        name: FinalAccounts.profitAndLoss.accName,
      ),
    );
  }
}