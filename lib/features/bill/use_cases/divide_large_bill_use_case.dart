import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';

import '../../../../core/constants/app_constants.dart';
import '../data/models/bill_items.dart';
import '../data/models/bill_model.dart';

class DivideLargeBillUseCase {
  /// 🔹 Splits a large bill into multiple smaller bills, ensuring each has at most `maxItemsPerBill` items.
  List<BillModel> execute(BillModel bill, {int maxItemsPerBill = AppConstants.maxItemsPerBill}) {
    final List<BillModel> splitBills = [];
    final List<BillItem> allItems = bill.items.itemList;

    // 🔹 Check if splitting is necessary
    if (allItems.length <= maxItemsPerBill) {
      return [bill]; // No need to split, return original bill as a single-item list
    }

    // 🔹 Split items into chunks based on `maxItemsPerBill`
    final List<List<BillItem>> itemChunks = _splitItemsIntoChunks(allItems, maxItemsPerBill);

    for (int i = 0; i < itemChunks.length; i++) {
      final newBill = bill.copyWith(
        billId: "${bill.billId}_part${i + 1}", // Unique identifier for split bills
        billDetails: bill.billDetails.copyWith(billNumber: bill.billDetails.billNumber! + i),
        items: BillItems(itemList: itemChunks[i]),
      );

      splitBills.add(newBill);
    }

    return splitBills;
  }

  /// 🔹 Splits a list of items into chunks of `maxItemsPerBill`
  List<List<BillItem>> _splitItemsIntoChunks(List<BillItem> items, int maxItemsPerBill) {
    return items.chunkBy((maxItemsPerBill));
  }
}