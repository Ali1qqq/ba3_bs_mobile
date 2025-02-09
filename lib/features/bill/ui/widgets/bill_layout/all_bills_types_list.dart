import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../users_management/data/models/role_model.dart';
import 'bill_type_item_widget.dart';
import 'bill_type_shimmer_widget.dart';

class AllBillsTypesList extends StatelessWidget {
  const AllBillsTypesList({super.key, required this.allBillsController});

  final AllBillsController allBillsController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: allBillsController.getBillsTypesRequestState.value == RequestState.loading
              ? List.generate(10, (index) => const BillTypeShimmerWidget()) // Show shimmer placeholders
              : RoleItemType.viewBill.hasAdminPermission
                  ? allBillsController.billsTypes
                      .map(
                        (billTypeModel) => BillTypeItemWidget(
                          text: billTypeModel.fullName!,
                          color: Color(billTypeModel.color!),
                          onTap: () {
                            allBillsController.openFloatingBillDetails(context, billTypeModel);
                            // allBillsController.fetchAllBillsByType( billTypeModel);
                          },
                          pendingBillsCounts: allBillsController.pendingBillsCounts(billTypeModel),
                          allBillsCounts: allBillsController.allBillsCounts(billTypeModel),
                          onPendingBillsPressed: () {
                            allBillsController.fetchPendingBills(billTypeModel);
                          },
                        ),
                      )
                      .toList()
                  : [
                      BillTypeItemWidget(
                        text: allBillsController.getSaleBillsType.fullName!,
                        color: Color(allBillsController.getSaleBillsType.color!),
                        onTap: () {
                          allBillsController.openFloatingBillDetails(context, allBillsController.getSaleBillsType);
                          // allBillsController.fetchAllBillsByType( billTypeModel);
                        },
                        pendingBillsCounts: allBillsController.pendingBillsCounts(allBillsController.getSaleBillsType),
                        allBillsCounts: allBillsController.allBillsCounts(allBillsController.getSaleBillsType),
                        onPendingBillsPressed: () {
                          allBillsController.fetchPendingBills(allBillsController.getSaleBillsType);
                        },
                      )
                    ],
        );
      },
    );
  }
}
