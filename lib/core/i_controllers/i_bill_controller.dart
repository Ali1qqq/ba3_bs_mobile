import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../features/accounts/data/models/account_model.dart';
import '../helper/enums/enums.dart';

abstract class IBillController extends GetxController {
  /// Updates the selected account additions or discounts
  void updateSelectedAdditionsDiscountAccounts(Account key, AccountModel value);

  void updateCustomerAccount(AccountModel? newAccount);

  Future<void> sendToEmail(
      {required String recipientEmail, String? url, String? subject, String? body, List<String>? attachments});

  set updateIsBillSaved(bool newValue);
}
