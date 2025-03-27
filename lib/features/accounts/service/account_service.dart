import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';

import '../../../core/helper/enums/enums.dart';

class AccountService {
  AccountModel? createAccountModel({
    AccountModel? accountModel,
    required String accName,
    required String accCode,
    required String accLatinName,
    required AccountType accType,
    String? accParentGuid,
    String? accParentName,
    required DateTime accCheckDate,
  }) {
    if (accountModel == null) {
      return AccountModel(
        accName: accName,
        accCode: accCode,
        accLatinName: accLatinName,
        accType: accType.index,
        accParentGuid: accParentGuid,
        accParentName: accParentName,
        accCheckDate: accCheckDate,
      );
    } else {
      return accountModel.copyWith(
        accName: accName,
        accCode: accCode,
        accLatinName: accLatinName,
        accType: accType.index,
        accParentGuid: accParentGuid,
        accParentName: accParentName,
        accCheckDate: accCheckDate,
      );
    }
  }
}