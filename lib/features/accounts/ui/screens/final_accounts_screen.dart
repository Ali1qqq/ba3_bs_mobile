import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/account_statement_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../../core/widgets/pluto_grid_with_dual_tables.dart';
import '../../../pluto/controllers/pluto_dual_table_controller.dart';

class FinalAccountScreen extends StatelessWidget {
  const FinalAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.finalAccounts.tr),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: FinalAccounts.values.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final account = FinalAccounts.values[index];
          return _buildAccountCard(context, account);
        },
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, FinalAccounts account) {
    final icon = _getIconForAccount(account);
    final gradient = _getGradientForAccount(account);

    return InkWell(
      onTap: () {
        read<AccountStatementController>().navigateToFinalAccountDetails(account);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                account.accName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }

  IconData _getIconForAccount(FinalAccounts account) {
    switch (account) {
      case FinalAccounts.tradingAccount:
        return Icons.shopping_cart;
      case FinalAccounts.profitAndLoss:
        return Icons.trending_up;
      case FinalAccounts.balanceSheet:
        return Icons.account_balance;
    }
  }

  LinearGradient _getGradientForAccount(FinalAccounts account) {
    switch (account) {
      case FinalAccounts.tradingAccount:
        return const LinearGradient(
          colors: [Color(0xFFF2994A), Color(0xFFF2C94C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case FinalAccounts.profitAndLoss:
        return const LinearGradient(
          colors: [Color(0xFF27AE60), Color(0xFF6FCF97)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case FinalAccounts.balanceSheet:
        return const LinearGradient(
          colors: [Color(0xFF2D9CDB), Color(0xFF56CCF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

// ///---------------------------
// ///test
// //المتاجرة 52396.43
// // الأرباح والخسائر 53448.81
// // الميزانية 13596.90
//
// ///---------------------------
// ///production
// // المتاجرة 2282791.72
// // الأرباح والخسائر 2554988.04
// // الميزانية 344946.52-

class FinalAccountDetailsScreen extends StatefulWidget {
  const FinalAccountDetailsScreen({super.key, required this.account});

  final FinalAccounts account;

  @override
  State<FinalAccountDetailsScreen> createState() => _FinalAccountDetailsScreenState();
}

class _FinalAccountDetailsScreenState extends State<FinalAccountDetailsScreen> {
  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchData();
  }

  Future<void> fetchData() async {
    final controller = read<AccountStatementController>();
    await controller.fetchFinalAccountsStatements(widget.account);

    read<PlutoDualTableController>().setData(controller.finalAccountsEntryBondItems);
  }

  @override
  Widget build(BuildContext context) {
    final controller = read<AccountStatementController>();
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        return PlutoGridWithDualTables(
          title: 'حركات ${widget.account.accName.tr}',
          isLoading: snapshot.connectionState == ConnectionState.waiting,
          bottomChild: _buildAccountSummary(controller), // Passing the summary
        );
      },
    );
  }

  /// Builds the summary section for Debit, Credit, and Total Balance.
  Widget _buildAccountSummary(AccountStatementController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('مدين (Debit)', controller.debitFinalAccountValue, Colors.blue),
          _buildSummaryItem('دائن (Credit)', controller.creditFinalAccountValue, Colors.red),
          _buildSummaryItem('الرصيد (Balance)', controller.totalFinalAccountValue, Colors.green),
        ],
      ),
    );
  }

  /// Helper method to create summary item widgets.
  Widget _buildSummaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 5),
        Text(
          AppUIUtils.formatDecimalNumberWithCommas(value),
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 24),
        ),
      ],
    );
  }
}