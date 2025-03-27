import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/account_statement_controller.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/bond_model.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/entry_bond_model.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/pay_item_model.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../accounts/data/models/account_model.dart';

class RotateBalancesUseCase {
  final Future<void> Function(BondModel) saveBond;
  final bool Function(String) migrationGuard;

  final void Function(String version) setCurrentVersion;

  RotateBalancesUseCase({
    required this.saveBond,
    required this.migrationGuard,
    required this.setCurrentVersion,
  });

  Future<void> execute(String currentYear) async {
    if (migrationGuard(currentYear)) return;

    // Temporarily switch to default version to fetch accountStatements
    setCurrentVersion(AppConstants.defaultVersion);

    final accountEntities = read<AccountsController>().accounts.map(AccountEntity.fromAccountModel).toList();
    final accountStatementController = read<AccountStatementController>();

    log("${accountEntities.length} عدد الحسابات", name: "RotateBalancesUseCase");

    final allAccountsStatement = await accountStatementController.fetchAccountsStatement(accountEntities);

    final entryBondItems = await accountStatementController.processEntryBondItemsInIsolateUseCase
        .execute(allAccountsStatement.values.expand((list) => list).toList());

    final totalDebit = entryBondItems.fold(
      0.0,
      (previousValue, element) => previousValue + (element.bondItemType == BondItemType.debtor ? element.amount! : 0),
    );

    final totalCredit = entryBondItems.fold(
      0.0,
      (previousValue, element) => previousValue + (element.bondItemType == BondItemType.creditor ? element.amount! : 0),
    );

    log('totalDebit: $totalDebit - totalCredit: $totalCredit', name: 'Debit & Credit');

    final isDebitCreditEquals = checkDebitCreditEquals(totalDebit, totalCredit);

    if (!isDebitCreditEquals) {
      AppUIUtils.onFailure('الحسابات ليست متساوية');
      log("❌ الحسابات ليست متساوية", name: "RotateBalancesUseCase");
      return;
    }

    // Restore current version
    setCurrentVersion(currentYear);

    if (migrationGuard(currentYear)) return;

    await saveBond(
      BondModel.fromBondData(
        bondType: BondType.openingEntry,
        note: '📌 قيد إفتتاحي خاص بترحيل الأرصدة للسنة الجديدة',
        payDate: DateTime.now().toIso8601String(),
        bondRecordsItems: generatePayItems(entryBondItems),
      ),
    );

    log("✅ تم تدوير الأرصدة بنجاح.");
  }

  List<PayItem> generatePayItems(List<EntryBondItemModel> entryBondItems) {
    return entryBondItems
        .map(
          (EntryBondItemModel item) => PayItem(
            entryCredit: item.bondItemType == BondItemType.creditor ? item.amount : 0,
            entryDebit: item.bondItemType == BondItemType.debtor ? item.amount : 0,
            entryAccountGuid: item.account.id,
            entryAccountName: item.account.name,
            entryDate: item.date,
            entryNote: item.note,
          ),
        )
        .toList();
  }

  bool checkDebitCreditEquals(double a, double b) => (a - b).abs() <= 1;
}