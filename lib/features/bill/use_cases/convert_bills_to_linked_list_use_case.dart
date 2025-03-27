import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';

import '../data/models/bill_model.dart';

class ConvertBillsToLinkedListUseCase {
  /// 🔹 Converts a list of bills into a **linked list structure** by assigning **previous** and **next** references.
  List<BillModel> execute(List<BillModel> bills) {
    // 1️⃣ Group bills by type (BillType ID)
    final groupedBills = bills.groupBy((bill) => bill.billTypeModel.billTypeId!);

    // 2️⃣ For each group, sort by billNumber and link previous/next bills
    final updatedGroups = groupedBills.values.map(
      (group) {
        group.sortBy((bill) => bill.billDetails.billNumber!);

        return group
            .mapIndexed(
              (index, bill) => bill.copyWith(
                billDetails: bill.billDetails.copyWith(
                  previous: index == 0 ? null : group[index - 1].billDetails.billNumber,
                  next: index == group.length - 1 ? null : group[index + 1].billDetails.billNumber,
                ),
              ),
            )
            .toList();
      },
    ).toList(); // Converts to List<List<BillModel>>

    // 3️⃣ Flatten the updated groups back into a single list
    return updatedGroups.flatten();
  }
}