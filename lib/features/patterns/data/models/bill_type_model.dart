import 'package:equatable/equatable.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bill/data/models/discount_addition_account_model.dart';
import '../../../pluto/data/models/pluto_adaptable.dart';

class BillTypeModel extends PlutoAdaptable with EquatableMixin {
  final String? id;
  final String? billTypeId;
  final String? shortName;
  final String? fullName;
  final String? latinShortName;
  final String? latinFullName;
  final String? billTypeLabel;
  final int? color;

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
      // Deserialize accounts map
      accounts: (json['accounts'] as Map<String, dynamic>?)?.map((billAccountLabel, accountModelJson) {
        Account billAccount = getBillAccountFromLabel(billAccountLabel);
        AccountModel accountModel = AccountModel.fromMap(accountModelJson);
        return MapEntry(billAccount, accountModel);
      }),
      discountAdditionAccounts: _deserializeDiscountAdditionAccounts(json['discountAdditionAccounts']),
    );
  }

  static Map<Account, List<DiscountAdditionAccountModel>>? _deserializeDiscountAdditionAccounts(
      Map<String, dynamic>? discountAdditionAccountsJson) {
    if (discountAdditionAccountsJson == null) return null;

    return discountAdditionAccountsJson.map((billAccountLabel, discountListJson) {
      Account billAccount = getBillAccountFromLabel(billAccountLabel);
      List<DiscountAdditionAccountModel> discountList = (discountListJson as List)
          .map((discountJson) => DiscountAdditionAccountModel.fromJson(discountJson))
          .toList();
      return MapEntry(billAccount, discountList);
    });
  }

  Map<String, dynamic> toJson() => {
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

  Map<String, dynamic>? _serializeDiscountAdditionAccounts(
      Map<Account, List<DiscountAdditionAccountModel>>? discountAdditionAccounts) {
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
      );

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([type]) => {
        PlutoColumn(title: 'billTypeId', field: 'billTypeId', type: PlutoColumnType.text()): billTypeId,
        PlutoColumn(title: 'shortName', field: 'shortName', type: PlutoColumnType.text()): shortName,
        PlutoColumn(title: 'fullName', field: 'fullName', type: PlutoColumnType.text()): fullName,
        PlutoColumn(title: 'latinShortName', field: 'latinShortName', type: PlutoColumnType.text()): latinShortName,
        PlutoColumn(title: 'latinFullName', field: 'latinFullName', type: PlutoColumnType.text()): latinFullName,
        PlutoColumn(title: 'billType', field: 'billType', type: PlutoColumnType.text()): billTypeLabel,
        PlutoColumn(title: 'color', field: 'color', type: PlutoColumnType.text()): color,
        PlutoColumn(title: 'accounts', field: 'accounts', type: PlutoColumnType.text()):
            accounts?.map((account, accountModel) => MapEntry(account.label, accountModel.toPlutoGridFormat())),
      };

  @override
  List<Object?> get props => [
        id,
        billTypeId,
        shortName,
        fullName,
        latinShortName,
        latinFullName,
        billTypeLabel,
        color,
        accounts,
        discountAdditionAccounts,
      ];
}

// Utility function to get an Account object from a string
Account getBillAccountFromLabel(String label) => BillAccounts.byLabel(label);
