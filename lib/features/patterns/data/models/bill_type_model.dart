import 'package:equatable/equatable.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bill/data/models/discount_addition_account_model.dart';

class BillTypeModel with EquatableMixin {
  final String? id;
  final String? billTypeId;
  final String? shortName;
  final String? fullName;
  final String? latinShortName;
  final String? latinFullName;
  final String? billTypeLabel;
  final int? color;
  final BillPatternType? billPatternType;

  // Using a map to store accounts with Account as the key and AccountModel as the value
  final Map<Account, AccountModel>? accounts;
  final Map<Account, List<DiscountAdditionAccountModel>>? discountAdditionAccounts;

  BillTypeModel({
    this.id,
    this.billTypeId,
    this.shortName,
    this.fullName,
    this.latinShortName,
    this.latinFullName,
    this.billTypeLabel,
    this.color,
    this.accounts,
    this.discountAdditionAccounts,
    this.billPatternType,
  });

  factory BillTypeModel.fromJson(Map<String, dynamic> json) {
    return BillTypeModel(
      billTypeId: json['billTypeId'],
      id: json['docId'],
      shortName: json['shortName'],
      fullName: json['fullName'],
      latinShortName: json['latinShortName'],
      latinFullName: json['latinFullName'],
      billTypeLabel: json['billType'],
      color: json['color'],
      billPatternType: BillPatternType.byValue(json['billType']),
      // Deserialize accounts map
      accounts: (json['accounts'] as Map<String, dynamic>?)?.map((billAccountLabel, accountModelJson) {
        Account billAccount = getBillAccountFromLabel(billAccountLabel);
        AccountModel accountModel = AccountModel.fromMap(accountModelJson);
        return MapEntry(billAccount, accountModel);
      }),
      discountAdditionAccounts: _deserializeDiscountAdditionAccounts(json['discountAdditionAccounts']),
    );
  }

  static Map<Account, List<DiscountAdditionAccountModel>>? _deserializeDiscountAdditionAccounts(Map<String, dynamic>? discountAdditionAccountsJson) {
    if (discountAdditionAccountsJson == null) return null;

    return discountAdditionAccountsJson.map((billAccountLabel, discountListJson) {
      Account billAccount = getBillAccountFromLabel(billAccountLabel);
      List<DiscountAdditionAccountModel> discountList =
      (discountListJson as List).map((discountJson) => DiscountAdditionAccountModel.fromJson(discountJson)).toList();
      return MapEntry(billAccount, discountList);
    });
  }

  Map<String, dynamic> toJson() =>
      {
        'docId': id,
        'billTypeId': billTypeId,
        'shortName': shortName,
        'fullName': fullName,
        'latinShortName': latinShortName,
        'latinFullName': latinFullName,
        'billType': billTypeLabel,
        'color': color,
        // Serialize accounts map
        'accounts': accounts?.map((billAccounts, accountModel) => MapEntry(billAccounts.label, accountModel.toMap())),

        'discountAdditionAccounts': _serializeDiscountAdditionAccounts(discountAdditionAccounts),
      };

  Map<String, dynamic>? _serializeDiscountAdditionAccounts(Map<Account, List<DiscountAdditionAccountModel>>? discountAdditionAccounts) {
    if (discountAdditionAccounts == null) return null;

    return discountAdditionAccounts.map((billAccount, discountList) {
      return MapEntry(billAccount.label, discountList.map((discount) => discount.toJson()).toList());
    });
  }

  BillTypeModel copyWith({
    String? id,
    String? billTypeId,
    String? shortName,
    String? fullName,
    String? latinShortName,
    String? latinFullName,
    String? billTypeLabel,
    int? color,
    String? store,
    BillPatternType? billPatternType,
    Map<Account, AccountModel>? accounts,
    Map<Account, List<DiscountAdditionAccountModel>>? discountAdditionAccounts,
  }) =>
      BillTypeModel(
          id: id ?? this.id,
          billTypeId: billTypeId ?? this.billTypeId,
          shortName: shortName ?? this.shortName,
          fullName: fullName ?? this.fullName,
          latinShortName: latinShortName ?? this.latinShortName,
          latinFullName: latinFullName ?? this.latinFullName,
          billTypeLabel: billTypeLabel ?? this.billTypeLabel,
          color: color ?? this.color,
          accounts: accounts ?? this.accounts,
          discountAdditionAccounts: discountAdditionAccounts ?? this.discountAdditionAccounts,
          billPatternType: billPatternType ?? this.billPatternType);


  @override
  List<Object?> get props =>
      [
        id,
        billTypeId,
        shortName,
        fullName,
        latinShortName,
        latinFullName,
        billTypeLabel,
        billPatternType,
        color,
        accounts,
        discountAdditionAccounts,
      ];
}

// Utility function to get an Account object from a string
Account getBillAccountFromLabel(String label) => BillAccounts.byLabel(label);
