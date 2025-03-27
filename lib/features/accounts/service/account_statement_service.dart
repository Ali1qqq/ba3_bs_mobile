import 'package:ba3_bs_mobile/core/helper/extensions/date_time/date_time_extensions.dart';

import '../../../core/helper/enums/enums.dart';
import '../../bond/data/models/entry_bond_model.dart';

class AccountStatementService {
  double calculateSum({required List<EntryBondItemModel> items, required BondItemType type}) => items.fold(
        0.0,
        (sum, item) => item.bondItemType == type ? sum + (item.amount ?? 0.0) : sum,
      );

  String get formattedToday => DateTime.now().dayMonthYear;

  String get formattedFirstDay => DateTime.now().copyWith(month: 1, day: 1).dayMonthYear;

  double getAmountSign(double? amount, BondItemType type) {
    if (amount == null) return 0;
    return type == BondItemType.debtor ? amount : -amount;
  }
}