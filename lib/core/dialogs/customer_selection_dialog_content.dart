import 'package:flutter/material.dart';

import '../../features/customer/data/models/customer_model.dart';

class CustomerSelectionDialogContent extends StatelessWidget {
  final List<CustomerModel> customers;
  final Function(CustomerModel selectedAccount) onCustomerTap;

  const CustomerSelectionDialogContent({
    super.key,
    required this.customers,
    required this.onCustomerTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: customers.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ListTile(
          title: Center(
            child: Text(
              customers[index].name!,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          onTap: () {
            // Trigger the callback with the selected account
            onCustomerTap(customers[index]);
          },
        );
      },
    );
  }
}