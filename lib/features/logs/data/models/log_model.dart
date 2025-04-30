import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/entry_bond_type_utils.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/entry_bond_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../bill/data/models/bill_model.dart';
import '../../../materials/data/models/materials/material_model.dart';
import '../../services/log_origin_factory.dart';

class LogModel {
  final String? docId;
  final String sourceId;
  final DateTime date;
  final int sourceNumber;
  final String sourceType;
  final String userName;
  final LogEventType eventType;
  final String note;

  LogModel({
    this.docId,
    required this.sourceId,
    required this.date,
    required this.sourceNumber,
    required this.sourceType,
    required this.userName,
    required this.eventType,
    required this.note,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) => LogModel(
        docId: json['docId'],
        sourceId: json['sourceId'],
        date: (json['date'] as Timestamp).toDate(),
        sourceNumber: json['sourceNumber'],
        sourceType: json['sourceType'],
        userName: json['userName'],
        eventType: LogEventType.byLabel(json['eventType']),
        note: json['note'],
      );

  LogOrigin resolveOrigin() => LogOriginFactory.resolve(this);

  factory LogModel.fromEntryBondModel({
    required EntryBondModel entry,
    required LogEventType eventType,
    required String userName,
    required int sourceNumber,
  }) {
    final sourceType = entry.origin!.getSourceType;
    return LogModel(
      sourceId: entry.origin!.originId!,
      date: DateTime.now(),
      sourceNumber: sourceNumber,
      sourceType: sourceType,
      userName: userName,
      eventType: eventType,
      note: 'حدث ${eventType.label} خاص ب $sourceType رقم $sourceNumber',
    );
  }

  factory LogModel.fromBillModel({
    required BillModel bill,
    required LogEventType eventType,
    required String userName,
  }) {
    final sourceType = BillType.byTypeGuide(bill.billTypeModel.billTypeId!).value;
    final int billNumber = bill.billDetails.billNumber!;

    return LogModel(
      sourceId: bill.billId!,
      date: DateTime.now(),
      sourceNumber: billNumber,
      sourceType: sourceType,
      userName: userName,
      eventType: eventType,
      note: 'حدث ${eventType.label} خاص ب $sourceType رقم $billNumber',
    );
  }

  factory LogModel.fromAccountModel({
    required AccountModel account,
    required LogEventType eventType,
    required String userName,
  }) {
    final sourceType = account.accName!;
    final int accountNumber = account.accNumber!;

    return LogModel(
      sourceId: account.id!,
      date: DateTime.now(),
      sourceNumber: accountNumber,
      sourceType: sourceType,
      userName: userName,
      eventType: eventType,
      note: 'حدث ${eventType.label} خاص ب حساب $sourceType رقم $accountNumber',
    );
  }

  factory LogModel.fromMaterialModel({
    required MaterialModel material,
    required LogEventType eventType,
    required String userName,
  }) {
    final sourceType = material.matName!;
    final int matBarCode = material.matBarCode!.toInt;

    return LogModel(
      sourceId: material.id!,
      date: DateTime.now(),
      sourceNumber: matBarCode,
      sourceType: sourceType,
      userName: userName,
      eventType: eventType,
      note: 'حدث ${eventType.label} خاص ب مادة $sourceType ذات الباركود رقم $matBarCode',
    );
  }

  Map<String, dynamic> toJson() => {
        'docId': docId,
        'sourceId': sourceId,
        'date': Timestamp.fromDate(date),
        'sourceNumber': sourceNumber,
        'sourceType': sourceType,
        'userName': userName,
        'eventType': eventType.label,
        'note': note,
      };

  LogModel copyWith({
    String? docId,
    String? sourceId,
    DateTime? date,
    int? sourceNumber,
    String? sourceType,
    String? userName,
    LogEventType? eventType,
    String? note,
  }) {
    return LogModel(
      docId: docId ?? this.docId,
      sourceId: sourceId ?? this.sourceId,
      date: date ?? this.date,
      sourceNumber: sourceNumber ?? this.sourceNumber,
      sourceType: sourceType ?? this.sourceType,
      userName: userName ?? this.userName,
      eventType: eventType ?? this.eventType,
      note: note ?? this.note,
    );
  }
}