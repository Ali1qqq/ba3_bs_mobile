import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/pluto/data/models/pluto_adaptable.dart';
import 'package:get/get.dart';
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
  final List<String>? accCustomer;

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
    this.accCustomer,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['AccPtr'] ?? json['docId'],
      accName: json['AccName'] ?? '',
      accLatinName: json['AccLatinName'] ?? '',
      accCode: json['AccCode'] ?? '',
      accCDate: json['AccCDate'] == null ? null : DateTime.tryParse(json['AccCDate']),
      accCheckDate: json['AccCheckDate'] == null ? null : DateTime.tryParse(json['AccCheckDate']),
      accParentGuid: json['AccParentGuid'] ?? '',
      accFinalGuid: json['AccFinalGuid'] ?? '',
      // accAccNSons: json['AccAccNSons']??0,
      // accInitDebit: (json['AccInitDebit'] as num?)?.toDouble(),
      // accInitCredit: (json['AccInitCredit'] as num?)?.toDouble(),
      // maxDebit: (json['MaxDebit'] as num?)?.toDouble(),
      // accWarn: json['AccWarn']??0,
      note: json['Note'] ?? '',
      // accCurVal: json['AccCurVal']??0,
      // accCurGuid: json['AccCurGuid']??'',
      // accSecurity: json['AccSecurity']??0,
      // accDebitOrCredit: json['AccDebitOrCredit']??0,
      accType: json['AccType'] ?? 0,
      // accState: json['AccState']??0,
      // accIsChangableRatio: json['AccIsChangableRatio']??0,
      // accBranchGuid: json['AccBranchGuid']??'',
      accNumber: int.tryParse(json['AccNumber'].toString()) ?? 0,
      // accBranchMask: json['AccBranchMask']??'',
      accParentName: json['accParentName'] ?? '',
      accCustomer: List<String>.from(json['accCustomer'] ?? []),
      // billsId: json['billsId'] ?? ["AQGmxAyLwBsHi9gTTsXn", "BuXK4e6GR6f5GFHf avRu"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docId': id,
      'AccName': accName,
      'AccLatinName': accLatinName,
      'AccCode': accCode,
      'AccCDate': accCDate?.toIso8601String() ?? DateTime.now(),
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
      'accCustomer': accCustomer,
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
    List<String>? accCustomer,
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
      accCustomer: accCustomer ?? this.accCustomer,
    );
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([type]) {
    return {
      PlutoColumn(field: AppStrings.identificationNumber.tr, type: PlutoColumnType.text(), title: AppConstants.accountIdFiled, hide: true):
          id,
      createAutoIdColumn(): '#',
      PlutoColumn(title: AppStrings.accountNumber.tr, type: PlutoColumnType.text(), field: 'رقم الحساب', width: 180): accNumber,
      PlutoColumn(title: AppStrings.accountCode.tr, type: PlutoColumnType.text(), field: 'رمز الحساب', width: 180): accCode,
      PlutoColumn(title: AppStrings.accountName.tr, type: PlutoColumnType.text(), field: 'اسم الحساب'): accName,
      PlutoColumn(title: AppStrings.latinName.tr, type: PlutoColumnType.text(), field: 'الاسم الاتيني'): accLatinName,
      PlutoColumn(title: AppStrings.accountType.tr, type: PlutoColumnType.text(), field: 'نوع الحساب'):
          AppServiceUtils.getAccountType(accType),
      PlutoColumn(title: AppStrings.fatherAccount.tr, type: PlutoColumnType.text(), field: 'حساب الاب'): accParentName,
      PlutoColumn(title: AppStrings.children.tr, type: PlutoColumnType.text(), field: 'الاولاد'):
          read<AccountsController>().getAccountChildren(id).join(' , '),
      PlutoColumn(title: AppStrings.customers.tr, type: PlutoColumnType.text(), field: 'الزبائن'): accCustomer?.toList().join(' , '),
    };
  }
}

class AccountEntity {
  final String id;
  final String name;

  const AccountEntity({
    required this.id,
    required this.name,
  });

  factory AccountEntity.fromJson(Map<String, dynamic> json) {
    return AccountEntity(
      id: json['AccPtr'],
      name: json['AccName'],
    );
  }

  factory AccountEntity.fromAccountModel(AccountModel accountModel) {
    return AccountEntity(
      id: accountModel.id!,
      name: accountModel.accName!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccPtr': id,
      'AccName': name,
    };
  }

  AccountEntity copyWith({
    String? id,
    String? name,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}