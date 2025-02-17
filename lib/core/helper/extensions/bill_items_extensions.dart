import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';

import '../../../features/bill/data/models/bill_items.dart';

extension BillItemsExtension on List<BillItem> {
  List<BillItem> merge<T>() => mergeBy(
        (item) => item.itemGuid,
        (a, b) => a.copyWith(
          itemQuantity: a.itemQuantity + b.itemQuantity,
          itemTotalPrice: (a.itemTotalPrice.toDouble + b.itemTotalPrice.toDouble).toStringAsFixed(2),
          itemSubTotalPrice: (a.itemSubTotalPrice ?? 0.0) + (b.itemSubTotalPrice ?? 0.0),
          itemVatPrice: (a.itemVatPrice ?? 0.0) + (b.itemVatPrice ?? 0.0),
          itemGiftsNumber: (a.itemGiftsNumber ?? 0) + (b.itemGiftsNumber ?? 0),
          itemGiftsPrice: (a.itemGiftsPrice ?? 0.0) + (b.itemGiftsPrice ?? 0.0),
        ),
      );
}