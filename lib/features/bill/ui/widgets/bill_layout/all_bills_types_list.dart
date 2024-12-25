import 'package:ba3_bs_mobile/core/widgets/item_widget.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';

class AllBillsTypesList extends StatelessWidget {
  const AllBillsTypesList({super.key, required this.allBillsController});

  final AllBillsController allBillsController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...allBillsController.billsTypes.map((billTypeModel) => ItemWidget(
              text: billTypeModel.fullName!,
              onTap: () {
                allBillsController
                  ..fetchAllBills()
                  ..openFloatingBillDetails(context, billTypeModel);
              },
            ))
      ],
    );
  }
}
