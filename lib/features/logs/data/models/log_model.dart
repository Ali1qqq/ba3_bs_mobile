import 'package:ba3_bs_mobile/core/helper/extensions/entry_bond_type_utils.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/entry_bond_model.dart';

import '../../../../core/helper/enums/enums.dart';

class LogModel {
  final String? id;
  final DateTime date;
  final int sourceNumber;
  final String sourceType;
  final String userName;
  final LogEventType eventType;
  final String note;

  LogModel({
    this.id,
    required this.date,
    required this.sourceNumber,
    required this.sourceType,
    required this.userName,
    required this.eventType,
    required this.note,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) => LogModel(
        id: json['docId'],
        date: DateTime.parse(json['date']),
        sourceNumber: json['sourceNumber'],
        sourceType: json['sourceType'],
        userName: json['userName'],
        eventType: LogEventType.byLabel(json['eventType']),
        note: json['note'],
      );

  factory LogModel.fromEntryBondModel({
    required EntryBondModel entry,
    required LogEventType eventType,
    required String userName,
    required int sourceNumber,
  }) {
    final sourceType = entry.origin!.getSourceType;
    return LogModel(
      date: DateTime.now(),
      sourceNumber: sourceNumber,
      sourceType: sourceType,
      userName: userName,
      eventType: eventType,
      note: 'حدث ${eventType.label} خاص بسند $sourceType رقم $sourceNumber',
    );
  }

  Map<String, dynamic> toJson() => {
        'docId': id,
        'date': date.toIso8601String(),
        'sourceNumber': sourceNumber,
        'sourceType': sourceType,
        'userName': userName,
        'eventType': eventType.label,
        'note': note,
      };

  LogModel copyWith({
    String? id,
    DateTime? date,
    int? sourceNumber,
    String? sourceType,
    String? userName,
    LogEventType? eventType,
    String? note,
  }) {
    return LogModel(
      id: id ?? this.id,
      date: date ?? this.date,
      sourceNumber: sourceNumber ?? this.sourceNumber,
      sourceType: sourceType ?? this.sourceType,
      userName: userName ?? this.userName,
      eventType: eventType ?? this.eventType,
      note: note ?? this.note,
    );
  }
}