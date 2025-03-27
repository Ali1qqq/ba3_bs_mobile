import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:flutter/material.dart';

class AccountSelectionDialogContent extends StatelessWidget {
  final List<AccountModel> accounts;
  final Function(AccountModel selectedAccount) onAccountTap;

  const AccountSelectionDialogContent({
    super.key,
    required this.accounts,
    required this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: accounts.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ListTile(
          title: Center(
            child: Text(
              accounts[index].accName!,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          onTap: () {
            // Trigger the callback with the selected account
            onAccountTap(accounts[index]);
          },
        );
      },
    );
  }
}