import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../core/helper/enums/enums.dart';
import '../../bond/data/models/entry_bond_model.dart';

class PlutoDualTableController extends GetxController {
  UniqueKey plutoKey = UniqueKey();

  List<EntryBondItemModel> debitItems = [];
  List<EntryBondItemModel> creditItems = [];

  void updatePlutoKey() {
    plutoKey = UniqueKey();
    update();
  }

  void setData(List<EntryBondItemModel> allItems) {
    debitItems = allItems.where((item) => item.bondItemType == BondItemType.debtor).toList();
    creditItems = allItems.where((item) => item.bondItemType == BondItemType.creditor).toList();
    update();
  }

  List<PlutoColumn> generateColumns(bool isDebit) {
    return [
      PlutoColumn(title: 'Account', field: 'account', type: PlutoColumnType.text()),
      PlutoColumn(
        title: isDebit ? 'Debit (مدين)' : 'Credit (دائن)',
        field: isDebit ? 'debit' : 'credit',
        type: PlutoColumnType.currency(
          format: '#,##0.00 AED',
          locale: 'en_AE',
          symbol: 'AED',
        ),
      ),
    ];
  }

  List<PlutoRow> generateRows(List<EntryBondItemModel> items, bool isDebit) {
    List<PlutoRow> rows = [];

    for (var item in items) {
      log('item account: ${item.account.name}, amount: ${item.amount}', name: 'generateRows');
      if (item.amount == null || item.amount == 0.0 || (item.amount ?? 0) < .01) continue; // ✅ Skip invalid amounts

      rows.add(
        PlutoRow(
          cells: {
            'account': PlutoCell(value: item.account.name),
            isDebit ? 'debit' : 'credit': PlutoCell(value: item.amount),
          },
        ),
      );
    }

    return rows;
  }
}
