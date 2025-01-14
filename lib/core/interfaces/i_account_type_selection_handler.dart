import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:get/get.dart';

abstract class IAccountTypeSelectionHandler {
  Rx<AccountType> get selectedAccountType;

  void onSelectedAccountTypeChanged(AccountType? newTax);
}
