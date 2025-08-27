import 'dart:developer';

import 'package:intl/intl.dart';

import '../../bond/data/models/entry_bond_model.dart';

class FilterEntryBondItemsByDateUseCase {
  List<EntryBondItemModel> execute(String startDate, String endDate,
      List<EntryBondItemModel> entryBondItems) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    final DateTime startDateFormat = dateFormat.parse(startDate);
    final DateTime endDateFormat = dateFormat.parse(endDate);

    return entryBondItems.where((item) {
      final String? entryBondItemDateStr = item.date;
      if (entryBondItemDateStr == null) return false;

      DateTime? entryBondItemDate;
      try {
        entryBondItemDate = dateFormat.parse(entryBondItemDateStr);
      } catch (e) {
        log('Error parsing item.date: $entryBondItemDateStr. Error: $e',
            name: 'FilterEntryBondItemsByDate');
        return false;
      }

      return entryBondItemDate
              .isAfter(startDateFormat.subtract(const Duration(days: 1))) &&
          entryBondItemDate
              .isBefore(endDateFormat.add(const Duration(days: 1)));
    }).toList();
  }
}
