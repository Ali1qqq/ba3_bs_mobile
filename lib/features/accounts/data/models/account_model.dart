import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/pluto/data/models/pluto_adaptable.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/pluto_auto_id_column.dart';

class AccountModel implements PlutoAdaptable {
  final String? id;
  final String? accName;
  final String? accLatinName;
  final String? accCode;
  final DateTime? accCDate;
  final DateTime? accCheckDate;
  final String? accParentGuid;
  final String? accParentName;
  final String? accFinalGuid;
  final int? accAccNSons;
  final double? accInitDebit;
  final double? accInitCredit;
  final double? maxDebit;
  final int? accWarn;
  final String? note;
  final int? accCurVal;
  final String? accCurGuid;
  final int? accSecurity;
  final int? accDebitOrCredit;
  final int? accType;
  final int? accState;
  final int? accIsChangableRatio;
  final String? accBranchGuid;
  final int? accNumber;
  final int? accBranchMask;

  // final List<String>? billsId;

  const AccountModel({
    this.id,
    this.accName,
    this.accLatinName,
    this.accCode,
    this.accCDate,
    this.accCheckDate,
    this.accParentGuid,
    this.accFinalGuid,
    this.accAccNSons,
    this.accInitDebit,
    this.accInitCredit,
    this.maxDebit,
    this.accWarn,
    this.note,
    this.accCurVal,
    this.accCurGuid,
    this.accSecurity,
    this.accDebitOrCredit,
    this.accType,
    this.accState,
    this.accIsChangableRatio,
    this.accBranchGuid,
    this.accNumber,
    this.accBranchMask,
    // this.billsId,
    this.accParentName,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['AccPtr'].toString(),
      accName: json['AccName'].toString(),
      accLatinName: json['AccLatinName'].toString(),
      accCode: json['AccCode'].toString(),
      accCDate: DateTime.tryParse(json['AccCDate']),
      accCheckDate: DateTime.tryParse(json['AccCheckDate']),
      accParentGuid: json['AccParentGuid'],
      accFinalGuid: json['AccFinalGuid'],
      accAccNSons: json['AccAccNSons'],
      accInitDebit: (json['AccInitDebit'] as num?)?.toDouble(),
      accInitCredit: (json['AccInitCredit'] as num?)?.toDouble(),
      maxDebit: (json['MaxDebit'] as num?)?.toDouble(),
      accWarn: json['AccWarn'],
      note: json['Note'].toString(),
      accCurVal: json['AccCurVal'],
      accCurGuid: json['AccCurGuid'],
      accSecurity: json['AccSecurity'],
      accDebitOrCredit: json['AccDebitOrCredit'],
      accType: json['AccType'],
      accState: json['AccState'],
      accIsChangableRatio: json['AccIsChangableRatio'],
      accBranchGuid: json['AccBranchGuid'],
      accNumber: json['AccNumber'],
      accBranchMask: json['AccBranchMask'],
      accParentName: json['accParentName'],
      // billsId: json['billsId'] ?? ["AQGmxAyLwBsHi9gTTsXn", "BuXK4e6GR6f5GFHfavRu"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccPtr': id,
      'AccName': accName,
      'AccLatinName': accLatinName,
      'AccCode': accCode,
      'AccCDate': accCDate?.toIso8601String(),
      'AccCheckDate': accCheckDate?.toIso8601String(),
      'AccParentGuid': accParentGuid,
      'AccFinalGuid': accFinalGuid,
      'AccAccNSons': accAccNSons,
      'AccInitDebit': accInitDebit,
      'AccInitCredit': accInitCredit,
      'MaxDebit': maxDebit,
      'AccWarn': accWarn,
      'Note': note,
      'AccCurVal': accCurVal,
      'AccCurGuid': accCurGuid,
      'AccSecurity': accSecurity,
      'AccDebitOrCredit': accDebitOrCredit,
      'AccType': accType,
      'AccState': accState,
      'AccIsChangableRatio': accIsChangableRatio,
      'AccBranchGuid': accBranchGuid,
      'AccNumber': accNumber,
      'AccBranchMask': accBranchMask,
      'accParentName': accParentName,
      // 'billsId': billsId?.toList() ?? [],
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> json) => AccountModel(
        id: json['AccPtr'].toString(),
        accName: json['AccName'].toString(),
      );

  Map<String, dynamic> toMap() => {
        'AccPtr': id,
        'AccName': accName,
      };

  AccountModel copyWith({
    String? id,
    String? accName,
    String? accLatinName,
    String? accCode,
    DateTime? accCDate,
    DateTime? accCheckDate,
    String? accParentGuid,
    String? accFinalGuid,
    int? accAccNSons,
    double? accInitDebit,
    double? accInitCredit,
    double? maxDebit,
    int? accWarn,
    String? note,
    int? accCurVal,
    String? accCurGuid,
    int? accSecurity,
    int? accDebitOrCredit,
    int? accType,
    int? accState,
    int? accIsChangableRatio,
    String? accBranchGuid,
    String? accParentName,
    int? accNumber,
    int? accBranchMask,
  }) {
    return AccountModel(
      id: id ?? this.id,
      accName: accName ?? this.accName,
      accLatinName: accLatinName ?? this.accLatinName,
      accCode: accCode ?? this.accCode,
      accCDate: accCDate ?? this.accCDate,
      accCheckDate: accCheckDate ?? this.accCheckDate,
      accParentGuid: accParentGuid ?? this.accParentGuid,
      accFinalGuid: accFinalGuid ?? this.accFinalGuid,
      accAccNSons: accAccNSons ?? this.accAccNSons,
      accInitDebit: accInitDebit ?? this.accInitDebit,
      accInitCredit: accInitCredit ?? this.accInitCredit,
      maxDebit: maxDebit ?? this.maxDebit,
      accWarn: accWarn ?? this.accWarn,
      note: note ?? this.note,
      accCurVal: accCurVal ?? this.accCurVal,
      accCurGuid: accCurGuid ?? this.accCurGuid,
      accSecurity: accSecurity ?? this.accSecurity,
      accDebitOrCredit: accDebitOrCredit ?? this.accDebitOrCredit,
      accType: accType ?? this.accType,
      accState: accState ?? this.accState,
      accIsChangableRatio: accIsChangableRatio ?? this.accIsChangableRatio,
      accBranchGuid: accBranchGuid ?? this.accBranchGuid,
      accNumber: accNumber ?? this.accNumber,
      accBranchMask: accBranchMask ?? this.accBranchMask,
      accParentName: accParentName ?? this.accParentName,
    );
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([type]) {
    return {
      PlutoColumn(field: 'الرقم التعريفي', type: PlutoColumnType.text(), title: 'الرقم التعريفي', hide: true): id,
      createAutoIdColumn(): '',
      PlutoColumn(field: 'رقم الحساب', type: PlutoColumnType.text(), title: 'رقم الحساب', width: 180): accNumber,
      PlutoColumn(field: 'رمز الحساب', type: PlutoColumnType.text(), title: 'رمز الحساب', width: 180): accCode,
      PlutoColumn(field: 'اسم الحساب', type: PlutoColumnType.text(), title: 'اسم الحساب'): accName,
      PlutoColumn(field: 'الاسم الاتيني', type: PlutoColumnType.text(), title: 'الاسم الاتيني'): accLatinName,
      PlutoColumn(field: 'نوع الحساب', type: PlutoColumnType.text(), title: 'نوع الحساب'): AppServiceUtils.getAccountType(accType),
      PlutoColumn(field: 'Debit Or Credit', type: PlutoColumnType.text(), title: 'نوع الدفع', width: 150):
          AppServiceUtils.getAccountAccDebitOrCredit(accDebitOrCredit),
      PlutoColumn(field: 'حساب الاب', type: PlutoColumnType.text(), title: 'حساب الاب'): accParentName,
      PlutoColumn(field: 'الاولاد', type: PlutoColumnType.text(), title: 'الاولاد'):
          read<AccountsController>().getAccountChildren(id).join(' , '),
    };
  }
}
