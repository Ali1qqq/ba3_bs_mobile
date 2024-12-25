import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../pluto/data/models/pluto_adaptable.dart';

class PayItems {
  final List<PayItem> itemList;

  PayItems({required this.itemList});

  factory PayItems.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['Item'] as List<dynamic>;
    List<PayItem> itemList = itemsJson.map((item) => PayItem.fromJson(item)).toList();
    return PayItems(itemList: itemList);
  }

  Map<String, dynamic> toJson() => {
        'Item': itemList.map((item) => item.toJson()).toList(),
      };

  factory PayItems.fromBondRecords(List<PayItem> bondRecords) {
    final itemList = bondRecords.map((bondRecord) {
      return PayItem(
          entryType: bondRecord.entryType,
          entryNote: bondRecord.entryNote,
          entryDate: bondRecord.entryDate,
          entryCustomerGuid: bondRecord.entryCustomerGuid,
          entryCurrencyVal: bondRecord.entryCurrencyVal,
          entryCurrencyGuid: bondRecord.entryCurrencyGuid,
          entryCostGuid: bondRecord.entryCostGuid,
          entryClass: bondRecord.entryClass,
          entryNumber: bondRecord.entryNumber,
          entryDebit: bondRecord.entryDebit,
          entryCredit: bondRecord.entryCredit,
          entryAccountGuid: bondRecord.entryAccountGuid,
          entryAccountName: bondRecord.entryAccountName);
    }).toList();

    return PayItems(itemList: itemList);
  }
}

class PayItem extends PlutoAdaptable<BondType> {
  final String? entryAccountGuid;
  final String? entryAccountName;
  final String? entryDate;
  final double? entryDebit;
  final double? entryCredit;
  final String? entryNote;
  final String? entryCurrencyGuid;
  final double? entryCurrencyVal;
  final String? entryCostGuid;
  final String? entryClass;
  final int? entryNumber;
  final String? entryCustomerGuid;
  final int? entryType;

  PayItem({
    this.entryAccountGuid,
    this.entryAccountName,
    this.entryDate,
    this.entryDebit,
    this.entryCredit,
    this.entryNote,
    this.entryCurrencyGuid,
    this.entryCurrencyVal,
    this.entryCostGuid,
    this.entryClass,
    this.entryNumber,
    this.entryCustomerGuid,
    this.entryType,
  });

  factory PayItem.fromJson(Map<String, dynamic> json) {
    return PayItem(
      entryAccountGuid: json['EntryAccountGuid'],
      entryAccountName: json['EntryAccountName'],
      entryDate: json['EntryDate'],
      entryDebit: json['EntryDebit'].toDouble(),
      entryCredit: json['EntryCredit'].toDouble(),
      entryNote: json['EntryNote'],
      entryCurrencyGuid: json['EntryCurrencyGuid'],
      entryCurrencyVal: json['EntryCurrencyVal'].toDouble(),
      entryCostGuid: json['EntryCostGuid'],
      entryClass: json['EntryClass'],
      entryNumber: json['EntryNumber'],
      entryCustomerGuid: json['EntryCustomerGuid'],
      entryType: json['EntryType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EntryAccountGuid': entryAccountGuid,
      'EntryAccountName': entryAccountName,
      'EntryDate': entryDate,
      'EntryDebit': entryDebit,
      'EntryCredit': entryCredit,
      'EntryNote': entryNote,
      'EntryCurrencyGuid': entryCurrencyGuid,
      'EntryCurrencyVal': entryCurrencyVal,
      'EntryCostGuid': entryCostGuid,
      'EntryClass': entryClass,
      'EntryNumber': entryNumber,
      'EntryCustomerGuid': entryCustomerGuid,
      'EntryType': entryType,
    };
  }

  PayItem copyWith({
    String? entryAccountGuid,
    String? entryAccountName,
    String? entryDate,
    double? entryDebit,
    double? entryCredit,
    String? entryNote,
    String? entryCurrencyGuid,
    double? entryCurrencyVal,
    String? entryCostGuid,
    String? entryClass,
    int? entryNumber,
    String? entryCustomerGuid,
    int? entryType,
  }) {
    return PayItem(
      entryAccountGuid: entryAccountGuid ?? this.entryAccountGuid,
      entryAccountName: entryAccountName ?? this.entryAccountName,
      entryDate: entryDate ?? this.entryDate,
      entryDebit: entryDebit ?? this.entryDebit,
      entryCredit: entryCredit ?? this.entryCredit,
      entryNote: entryNote ?? this.entryNote,
      entryCurrencyGuid: entryCurrencyGuid ?? this.entryCurrencyGuid,
      entryCurrencyVal: entryCurrencyVal ?? this.entryCurrencyVal,
      entryCostGuid: entryCostGuid ?? this.entryCostGuid,
      entryClass: entryClass ?? this.entryClass,
      entryNumber: entryNumber ?? this.entryNumber,
      entryCustomerGuid: entryCustomerGuid ?? this.entryCustomerGuid,
      entryType: entryType ?? this.entryType,
    );
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([BondType? type]) {
    return {

      PlutoColumn(
        title: "رقم ",
        field: AppConstants.entryNumber,
        width: 100,
        type: PlutoColumnType.text(),
        readOnly: true,
        renderer: (rendererContext) {
          if (rendererContext.cell.row.cells[AppConstants.entryAccountGuid]?.value != '') {
            return Text((rendererContext.rowIdx + 1).toString());
          } else {
            return const Text("");
          }
        },
      ): entryNumber,
      PlutoColumn(
          title: "دائن",
          field: AppConstants.entryCredit,
          type: PlutoColumnType.text(),
          hide: type == BondType.paymentVoucher): entryCredit,
      PlutoColumn(
          title: "مدين",
          field: AppConstants.entryDebit,
          type: PlutoColumnType.text(),
          hide: type == BondType.receiptVoucher): entryDebit,
      PlutoColumn(title: "الحساب", field: AppConstants.entryAccountGuid, type: PlutoColumnType.text()):
          entryAccountName,
      PlutoColumn(title: "البيان", field: AppConstants.entryNote, type: PlutoColumnType.text()): entryNote,
    };
  }

  factory PayItem.fromJsonPluto({required Map<String, dynamic> row, required String accId}) {
    return PayItem(
      entryAccountGuid: accId,
      entryAccountName: row[AppConstants.entryAccountGuid],
      entryCredit: double.tryParse(row[AppConstants.entryCredit].toString()) ?? 0,
      entryDebit: double.tryParse(row[AppConstants.entryDebit].toString()) ?? 0,
      entryNumber: int.tryParse(row[AppConstants.entryNumber].toString()) ?? 0,
      entryClass: '',
      entryCostGuid: "00000000-0000-0000-0000-000000000000",
      entryCurrencyGuid: "884edcde-c172-490d-a2f2-f10a0b90326a",
      entryCurrencyVal: 1,
      entryCustomerGuid: row[AppConstants.entryCustomerGuid],
      entryDate: Timestamp.now().toDate().toIso8601String(),
      entryNote: row[AppConstants.entryNote],
      entryType: 0,
    );
  }
}
