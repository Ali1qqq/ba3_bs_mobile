import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../../core/helper/enums/enums.dart';
import 'bill_type_item_widget.dart';

class AllBillsTypesList extends StatelessWidget {
  const AllBillsTypesList({super.key, required this.allBillsController});

  final AllBillsController allBillsController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...allBillsController.billsTypes.map(
          (billTypeModel) => Obx(
            () => BillTypeItemWidget(
              text: billTypeModel.fullName!,
              isLoading: allBillsController.getBillsByTypeRequestState.value == RequestState.loading,
              color: Color(billTypeModel.color!),
              onTap: () {
                allBillsController.openFloatingBillDetails(context, billTypeModel);
              },
              pendingBillsCounts: allBillsController.pendingBillsCounts(billTypeModel),
              allBillsCounts: allBillsController.allBillsCounts(billTypeModel),
              onPendingBillsPressed: () {
                allBillsController
                  ..fetchPendingBills(billTypeModel)
                  ..navigateToPendingBillsScreen();
              },
            ),
          ),
        )
      ],
    );
  }
}
