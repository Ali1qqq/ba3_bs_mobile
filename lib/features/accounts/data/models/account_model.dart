import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/pluto/data/models/pluto_adaptable.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/pluto_auto_id_column.dart';

part 'account_model.g.dart';

@HiveType(typeId: 10)
class AccountModel implements PlutoAdaptable {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? accName;

  @HiveField(2)
  final String? accLatinName;

  @HiveField(3)
  final String? accCode;

  @HiveField(4)
  final DateTime? accCDate;

  @HiveField(5)
  final DateTime? accCheckDate;

  @HiveField(6)
  final String? accParentGuid;

  @HiveField(7)
  final String? accParentName;

  @HiveField(8)
  final String? accFinalGuid;

  @HiveField(9)
  final int? accAccNSons;

  @HiveField(10)
  final double? accInitDebit;

  @HiveField(11)
  final double? accInitCredit;

  @HiveField(12)
  final double? maxDebit;

  @HiveField(13)
  final int? accWarn;

  @HiveField(14)
  final String? note;

  @HiveField(15)
  final int? accCurVal;

  @HiveField(16)
  final String? accCurGuid;

  @HiveField(17)
  final int? accSecurity;

  @HiveField(18)
  final int? accDebitOrCredit;

  @HiveField(19)
  final int? accType;

  @HiveField(20)
  final int? accState;

  @HiveField(21)
  final int? accIsChangableRatio;

  @HiveField(22)
  final String? accBranchGuid;

  @HiveField(23)
  final int? accNumber;

  @HiveField(24)
  final int? accBranchMask;

  @HiveField(25)
  final List<String>? accCustomer;
  @HiveField(26)
  final bool? requiredRequestNumber;

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
    this.requiredRequestNumber,
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
      accAccNSons: json['AccAccNSons'] ?? 0,
      requiredRequestNumber: json['requiredRequestNumber'] ?? false,
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
      'AccCDate': (accCDate ?? DateTime.now()).toIso8601String(),
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
      'requiredRequestNumber': requiredRequestNumber,
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
    bool? requiredRequestNumber,
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
      requiredRequestNumber: requiredRequestNumber ?? this.requiredRequestNumber,
    );
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([type]) {
    return {
      PlutoColumn(field: AppConstants.accountIdFiled, type: PlutoColumnType.text(), title: AppStrings.identificationNumber.tr, hide: true):
          id,
      createAutoIdColumn(): '#',
      createCheckColumn(): '',
      PlutoColumn(title: AppStrings.accountNumber.tr, type: PlutoColumnType.text(), field: 'رقم الحساب', width: 180): accNumber,
      PlutoColumn(title: AppStrings.accountCode.tr, type: PlutoColumnType.text(), field: 'رمز الحساب', width: 180): accCode,
      PlutoColumn(title: AppStrings.accountName.tr, type: PlutoColumnType.text(), field: 'اسم الحساب'): accName,
      PlutoColumn(title: AppStrings.latinName.tr, type: PlutoColumnType.text(), field: 'الاسم الاتيني'): accLatinName,
      PlutoColumn(title: AppStrings.accountType.tr, type: PlutoColumnType.text(), field: 'نوع الحساب'):
          AppServiceUtils.getAccountType(accType),
      PlutoColumn(title: AppStrings.fatherAccount.tr, type: PlutoColumnType.text(), field: 'حساب الاب'): accParentName,
      PlutoColumn(title: AppStrings.children.tr, type: PlutoColumnType.text(), field: 'الاولاد'):
          read<AccountsController>().getAccountChildrenNames(id).join(' , '),
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