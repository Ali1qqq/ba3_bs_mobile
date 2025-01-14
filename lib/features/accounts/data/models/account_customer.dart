import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/pluto/data/models/pluto_adaptable.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/generate_id.dart';

class AccountCustomer implements PlutoAdaptable {
  String? customerVAT;
  String? customerCardNumber;
  String? customerAccountName;
  String? mainAccount;
  String? customerAccountId;

  // Constructor
  AccountCustomer({
    this.customerVAT,
    this.customerCardNumber,
    this.customerAccountName,
    this.mainAccount,
    this.customerAccountId,
  });

  // fromJson: لتحويل البيانات من JSON إلى كائن AccountCustomer
  AccountCustomer.fromJson(Map<dynamic, dynamic> json) {
    customerVAT = json['customerVAT'];
    customerCardNumber = json['customerCardNumber'];
    customerAccountName = json['customerAccountName'];
    mainAccount = json['mainAccount'];
    customerAccountId = json['customerAccountId'];
  }

  AccountCustomer.fromJsonPluto(Map<dynamic, dynamic> json, String mainAccountId) {
    customerVAT = json['customerVAT'];
    customerCardNumber = json['customerCardNumber'];
    customerAccountName = json['customerAccountName'];
    mainAccount = mainAccountId;
    customerAccountId = json['customerAccountId'] ?? generateId(RecordType.accCustomer);
  }

  // toJson: لتحويل كائن AccountCustomer إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'customerVAT': customerVAT,
      'customerCardNumber': customerCardNumber,
      'customerAccountName': customerAccountName,
      'mainAccount': mainAccount,
      'customerAccountId': customerAccountId,
    };
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([void _]) {
    return {
      PlutoColumn(
        title: 'الرقم',
        field: 'customerAccountId',
        readOnly: true,
        hide: true,
        type: PlutoColumnType.text(),
      ): customerAccountId,
      PlutoColumn(title: 'رقم بطاقة الزبون', field: 'customerCardNumber', type: PlutoColumnType.text()): customerCardNumber,
      PlutoColumn(
        title: 'اسم الزبون',
        field: 'customerAccountName',
        type: PlutoColumnType.text(),
      ): customerAccountName,
      PlutoColumn(
        title: 'نوع الضريبة',
        field: 'customerVAT',
        type: PlutoColumnType.select([AppConstants.mainVATCategory, AppConstants.withoutVAT]),
      ): customerVAT,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'customerAccountId': customerAccountId,
      'رقم بطاقة الزبون': customerCardNumber,
      'اسم الزبون': customerAccountName,
      'الحساب': read<AccountsController>().getAccountNameById(mainAccount),
      'نوع الضريبة': customerVAT,
    };
  }

  // Override for toString: عرض معلومات الكائن بشكل نصي
  @override
  String toString() {
    return 'AccountCustomer(customerVAT: $customerVAT, customerCardNumber: $customerCardNumber, customerAccountName: $customerAccountName, mainAccount: $mainAccount, account: $customerAccountId)';
  }

  // Override for hashCode: لتمثيل الكائن برمز خاص لاستخدامه في مجموعات
  @override
  int get hashCode {
    return customerVAT.hashCode ^
        customerCardNumber.hashCode ^
        customerAccountName.hashCode ^
        mainAccount.hashCode ^
        customerAccountId.hashCode;
  }

  // Override for equality (==): للمقارنة بين الكائنات
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccountCustomer &&
        other.customerVAT == customerVAT &&
        other.customerCardNumber == customerCardNumber &&
        other.customerAccountName == customerAccountName &&
        other.mainAccount == mainAccount &&
        other.customerAccountId == customerAccountId;
  }
}
