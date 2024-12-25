import 'package:ba3_bs_mobile/features/bond/data/models/pay_item_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../../core/helper/enums/enums.dart';

class BondModel  {
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

  Map<String, dynamic> toJson() {
    return {
      'PayTypeGuid': payTypeGuid!,
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
    return BondModel(payAccountGuid: '',  payItems: PayItems(itemList: []), payNumber: lastBondNumber + 1, payTypeGuid: bondType.typeGuide, payDate: DateTime.now().toIso8601String());
  }



  factory BondModel.fromBondData({
    BondModel? bondModel,
    required BondType bondType,
    required note,
    required String payAccountGuid,
    required String payDate,
    required List<PayItem> bondRecordsItems,
  }) {
    final items = PayItems.fromBondRecords(bondRecordsItems);
    if (bondType == BondType.journalVoucher || bondType == BondType.openingEntry) payAccountGuid = "00000000-0000-0000-0000-000000000000";

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
}
