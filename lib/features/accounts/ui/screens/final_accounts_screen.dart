import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: FinalAccounts.values.map((account) {
            return Column(
              children: [
                _buildAccountCard(account),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAccountCard(FinalAccounts account) => Card(
        elevation: 4,
        color: AppColors.lightBlueColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(_getIconForAccount(account), size: 32, color: Colors.white),
          title: Text(account.accName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.white),
          onTap: () {
            read<AccountStatementController>().navigateToFinalAccountDetails(account);
          },
        ),
      );

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
}
//
// class FinalAccountDetailsScreen extends StatefulWidget {
//   const FinalAccountDetailsScreen({super.key, required this.account});
//
//   final FinalAccounts account;
//
//   @override
//   State<FinalAccountDetailsScreen> createState() => _FinalAccountDetailsScreenState();
// }
//
// class _FinalAccountDetailsScreenState extends State<FinalAccountDetailsScreen> {
//   late Future<void> _fetchDataFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchDataFuture = fetchData();
//   }
//
//   Future<void> fetchData() async => read<AccountStatementController>().fetchFinalAccountsStatements(widget.account);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<void>(
//         future: _fetchDataFuture,
//         builder: (context, snapshot) {
//           final controller = read<AccountStatementController>();
//           return PlutoGridWithAppBar(
//             title: 'حركات ${widget.account.accName.tr}',
//             onLoaded: (e) {},
//             onSelected: (event) {
//               String originId = event.row?.cells[AppConstants.entryBonIdFiled]?.value;
//               controller.launchBondEntryBondScreen(context: context, originId: originId);
//             },
//             isLoading: snapshot.connectionState == ConnectionState.waiting,
//             tableSourceModels: controller.finalAccountsEntryBondItems,
//             bottomChild: _buildAccountSummary(controller),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildAccountSummary(AccountStatementController controller) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildSummaryItem(AppStrings.debtor.tr, controller.debitFinalAccountValue),
//           _buildSummaryItem(AppStrings.creditor.tr, controller.creditFinalAccountValue),
//           _buildSummaryItem(AppStrings.theTotal.tr, controller.totalFinalAccountValue),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryItem(String label, double value) {
//     return Row(
//       children: [
//         Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 24)),
//         const SizedBox(width: 10),
//         Text(
//           AppUIUtils.formatDecimalNumberWithCommas(value),
//           style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 32),
//         ),
//       ],
//     );
//   }
// }
//
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