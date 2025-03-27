import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/date_format_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/pay_item_model.dart';
import 'package:ba3_bs_mobile/features/pluto/data/models/pluto_adaptable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/widgets/pluto_auto_id_column.dart';

class BondModel extends PlutoAdaptable {
  final String? payTypeGuid;
  final int? payNumber;
  final String? payGuid;
  final String? payBranchGuid;
  final String? payDate;
  final String? entryPostDate;
  final String? payNote;
  final String? payCurrencyGuid;
  final double? payCurVal;
  final String? payAccountGuid;
  final int? paySecurity;
  final int? paySkip;
  final int? erParentType;
  final PayItems payItems;
  final String? e;

  BondModel({
    this.payTypeGuid,
    this.payNumber,
    this.payGuid,
    this.payBranchGuid,
    this.payDate,
    this.entryPostDate,
    this.payNote,
    this.payCurrencyGuid,
    this.payCurVal,
    this.payAccountGuid,
    this.paySecurity,
    this.paySkip,
    this.erParentType,
    required this.payItems,
    this.e,
  });

  factory BondModel.fromJson(Map<String, dynamic> json) {
    return BondModel(
      payTypeGuid: json['PayTypeGuid'],
      payNumber: json['PayNumber'],
      payGuid: json['docId'],
      payBranchGuid: json['PayBranchGuid'],
      payDate: json['PayDate'],
      entryPostDate: json['EntryPostDate'],
      payNote: json['PayNote'],
      payCurrencyGuid: json['PayCurrencyGuid'],
      payCurVal: json['PayCurVal'].toDouble(),
      payAccountGuid: json['PayAccountGuid'],
      paySecurity: json['PaySecurity'],
      paySkip: json['PaySkip'],
      erParentType: json['ErParentType'],
      payItems: PayItems.fromJson(json['PayItems'] ?? {}),
      e: json['E'],
    );
  }

  factory BondModel.fromBondData({
    BondModel? bondModel,
    String? payAccountGuid,
    required BondType bondType,
    required note,
    required String payDate,
    required List<PayItem> bondRecordsItems,
  }) {
    final items = PayItems.fromBondRecords(bondRecordsItems);

    if (bondType == BondType.journalVoucher || bondType == BondType.openingEntry) {
      payAccountGuid = "00000000-0000-0000-0000-000000000000";
    }

    return bondModel == null
        ? BondModel(
            payItems: items,
            e: "E=2",
            erParentType: 4,
            payCurrencyGuid: "00000000-0000-0000-0000-000000000000",
            payBranchGuid: "884edcde-c172-490d-a2f2-f10a0b90326a",
            entryPostDate: Timestamp.now().toDate().toString(),
            paySecurity: 1,
            paySkip: 0,
            payCurVal: 1,
            payAccountGuid: payAccountGuid,
            payTypeGuid: bondType.typeGuide,
            payDate: payDate,
            payNote: note,
          )
        : bondModel.copyWith(
            e: "E=2",
            erParentType: 4,
            payBranchGuid: "00000000-0000-0000-0000-000000000000",
            payCurrencyGuid: "884edcde-c172-490d-a2f2-f10a0b90326a",
            entryPostDate: Timestamp.now().toDate().toString(),
            paySecurity: 1,
            paySkip: 0,
            payCurVal: 1,
            payAccountGuid: payAccountGuid,
            payTypeGuid: bondType,
            payItems: items,
            payDate: payDate,
            payNote: note,
          );
  }

  Map<String, dynamic> toJson() {
    return {
      'PayTypeGuid': payTypeGuid,
      'PayNumber': payNumber,
      'docId': payGuid,
      'PayBranchGuid': payBranchGuid,
      'PayDate': payDate,
      'EntryPostDate': entryPostDate,
      'PayNote': payNote,
      'PayCurrencyGuid': payCurrencyGuid,
      'PayCurVal': payCurVal,
      'PayAccountGuid': payAccountGuid,
      'PaySecurity': paySecurity,
      'PaySkip': paySkip,
      'ErParentType': erParentType,
      'PayItems': payItems.toJson(),
      'E': e,
    };
  }

  factory BondModel.empty({required BondType bondType, int lastBondNumber = 0}) {
    return BondModel(
        payAccountGuid: '',
        payItems: PayItems(itemList: []),
        payNumber: lastBondNumber + 1,
        payTypeGuid: bondType.typeGuide,
        payDate: DateTime.now().toIso8601String());
  }

  BondModel copyWith({
    BondType? payTypeGuid,
    int? payNumber,
    String? payGuid,
    String? payBranchGuid,
    String? payDate,
    String? entryPostDate,
    String? payNote,
    String? payCurrencyGuid,
    double? payCurVal,
    String? payAccountGuid,
    int? paySecurity,
    int? paySkip,
    int? erParentType,
    PayItems? payItems,
    String? e,
  }) {
    return BondModel(
      payTypeGuid: payTypeGuid?.typeGuide ?? this.payTypeGuid,
      payNumber: payNumber ?? this.payNumber,
      payGuid: payGuid ?? this.payGuid,
      payBranchGuid: payBranchGuid ?? this.payBranchGuid,
      payDate: payDate ?? this.payDate,
      entryPostDate: entryPostDate ?? this.entryPostDate,
      payNote: payNote ?? this.payNote,
      payCurrencyGuid: payCurrencyGuid ?? this.payCurrencyGuid,
      payCurVal: payCurVal ?? this.payCurVal,
      payAccountGuid: payAccountGuid ?? this.payAccountGuid,
      paySecurity: paySecurity ?? this.paySecurity,
      paySkip: paySkip ?? this.paySkip,
      erParentType: erParentType ?? this.erParentType,
      payItems: payItems ?? this.payItems,
      e: e ?? this.e,
    );
  }

  factory BondModel.fromImportedJsonFile(Map<String, dynamic> payJson) {
    final payItemsJson = payJson["PayItems"]["N"] as List<dynamic>;
    final List<PayItem> payItemsList = payItemsJson.map((item) {
      return PayItem.fromJsonFile(item);
    }).toList();

    // إنشاء كائن PayItems
    final payItems = PayItems(itemList: payItemsList);
    DateFormat dateFormat = DateFormat('yyyy-M-d');
    // إنشاء كائن BondModel باستخدام البيانات المستخرجة
    return BondModel(
      payTypeGuid: payJson["PayTypeGuid"],
      payNumber: payJson["PayNumber"],
      payGuid: payJson["PayGuid"],
      payBranchGuid: payJson["PayBranchGuid"],
      payDate: dateFormat.parse(payJson["PayDate"].toString().toYearMonthDayFormat()).dayMonthYear,
      entryPostDate: payJson["EntryPostDate"],
      payNote: payJson["PayNote"].toString(),
      payCurrencyGuid: payJson["PayCurrencyGuid"],
      payCurVal: (payJson["PayCurVal"] as num).toDouble(),
      payAccountGuid: payJson["PayAccountGuid"],
      paySecurity: payJson["PaySecurity"],
      paySkip: payJson["PaySkip"],
      erParentType: payJson["ErParentType"],
      payItems: payItems,
      e: payJson["E"],
    );
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([type]) {
    return {
      PlutoColumn(
        title: AppConstants.bondIdFiled,
        field: AppConstants.bondIdFiled,
        type: PlutoColumnType.text(),
        hide: true,
      ): payGuid,
      createAutoIdColumn(): '#',
      PlutoColumn(title: 'رقم السند', field: 'رقم السند', type: PlutoColumnType.text()): payNumber,
      PlutoColumn(title: 'تاريخ السند', field: 'تاريخ السند', type: PlutoColumnType.date()): payDate,
      PlutoColumn(title: 'المبلغ', field: 'المبلغ', type: PlutoColumnType.number()): payItems.itemList.fold(
        0.0,
        (previousValue, element) => previousValue + element.entryDebit!,
      ),
      PlutoColumn(title: 'الحسابات المتأثرة', field: 'الحسابات', type: PlutoColumnType.text(), width: 0.6.sw): payItems.itemList
          .map(
            (item) => item.entryAccountName,
          )
          .toList()
          .join(', '),
      PlutoColumn(
        title: 'type',
        field: 'type',
        type: PlutoColumnType.text(),
        hide: true,
      ): payTypeGuid,
    };
  }
}